package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users
type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db}
}

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	user := req.ToUser()

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, name, email, created_at, updated_at`

	row := r.db.QueryRow(query,
		user.Name,
		user.Email,
	)

	err := user.ScanRow(row)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users 
		WHERE id = ? AND deleted_at IS NULL`

	row := r.db.QueryRow(query, id)

	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users 
		WHERE email = ? AND deleted_at IS NULL`

	row := r.db.QueryRow(query, email)

	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE deleted_at IS NULL
		ORDER BY created_at`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %v", err)
	}
	defer rows.Close()

	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, fmt.Errorf("failed to scan users: %v", err)
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// First check if user exists
	_, err := r.GetByID(id)
	if err != nil {
		return nil, err
	}

	var setValues []string
	var args []interface{}

	if req.Name != nil {
		setValues = append(setValues, "name = ?")
		args = append(args, *req.Name)
	}

	if req.Email != nil {
		setValues = append(setValues, "email = ?")
		args = append(args, *req.Email)
	}

	if len(setValues) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	// Always update the updated_at timestamp
	setValues = append(setValues, "updated_at = ?")
	args = append(args, time.Now())

	// Create update query
	updateQuery := fmt.Sprintf(`
        UPDATE users 
        SET %s
        WHERE id = ? AND deleted_at IS NULL`,
		strings.Join(setValues, ", "))

	args = append(args, id)

	// Execute update
	_, err = r.db.Exec(updateQuery, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	// Get updated user
	updatedUser, err := r.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("failed to get updated user: %v", err)
	}

	return updatedUser, nil
}

func (r *UserRepository) Delete(id int) error {
	query := `
		UPDATE users
		SET deleted_at = CURRENT_TIMESTAMP
		WHERE id = ? AND deleted_at IS NULL`

	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user with id %d does not exist or is already deleted", id)
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `
		SELECT COUNT(*) 
		FROM users
		WHERE deleted_at IS NULL`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}

	return count, nil
}
