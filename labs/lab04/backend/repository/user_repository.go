package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users
// This repository demonstrates MANUAL SQL approach with database/sql package
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create creates a new user in the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %v", err)
	}

	user := req.ToUser()

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, ?, ?)
		RETURNING id, name, email, created_at, updated_at
	`

	row := r.db.QueryRow(query, user.Name, user.Email, user.CreatedAt, user.UpdatedAt)

	if err := user.ScanRow(row); err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return user, nil
}

// GetByID gets user by ID from database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = ? AND deleted_at IS NULL
	`

	row := r.db.QueryRow(query, id)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by ID: %v", err)
	}

	return &user, nil
}

// GetByEmail gets user by email from database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = ? AND deleted_at IS NULL
	`

	row := r.db.QueryRow(query, email)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by email: %v", err)
	}

	return &user, nil
}

// GetAll gets all users from database
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE deleted_at IS NULL
		ORDER BY created_at
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all users: %v", err)
	}

	return models.ScanUsers(rows)
}

// Update updates user in database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Check if user exists
	existingUser, err := r.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Build dynamic UPDATE query
	var setParts []string
	var args []interface{}

	if req.Name != nil {
		setParts = append(setParts, "name = ?")
		args = append(args, *req.Name)
	}

	if req.Email != nil {
		setParts = append(setParts, "email = ?")
		args = append(args, *req.Email)
	}

	if len(setParts) == 0 {
		return existingUser, nil // No changes
	}

	setParts = append(setParts, "updated_at = ?")
	args = append(args, time.Now())
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = ? AND deleted_at IS NULL
	`, strings.Join(setParts, ", "))

	result, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return nil, fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}

	// Get updated user
	return r.GetByID(id)
}

// Delete deletes user from database
func (r *UserRepository) Delete(id int) error {
	// Check if user exists
	_, err := r.GetByID(id)
	if err != nil {
		return err
	}

	query := `
		UPDATE users
		SET deleted_at = ?
		WHERE id = ? AND deleted_at IS NULL
	`

	result, err := r.db.Exec(query, time.Now(), id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// Count counts total number of users
func (r *UserRepository) Count() (int, error) {
	query := `
		SELECT COUNT(*)
		FROM users
		WHERE deleted_at IS NULL
	`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}

	return count, nil
}
