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

// NewUserRepository creates a new UserRepository instance with the given database connection
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db}
}

// Create validates and inserts a new user record into the database.
// Returns the created user or an error if validation fails or insert fails.
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

// GetByID retrieves a user by their ID from the database.
// Returns the user or an error if the user is not found or query fails.
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

// GetByEmail retrieves a user by their email address from the database.
// Returns the user or an error if the user is not found or query fails.
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

// GetAll retrieves all non-deleted users from the database ordered by creation time.
// Returns a slice of users or an error if the query fails.
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

// Update modifies an existing user's details in the database.
// Returns the updated user or an error if the user doesn't exist or update fails.
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
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

	setValues = append(setValues, "updated_at = ?")
	args = append(args, time.Now())

	updateQuery := fmt.Sprintf(`
		UPDATE users 
		SET %s
		WHERE id = ? AND deleted_at IS NULL`,
		strings.Join(setValues, ", "))

	args = append(args, id)

	_, err = r.db.Exec(updateQuery, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	updatedUser, err := r.GetByID(id)
	if err != nil {
		return nil, fmt.Errorf("failed to get updated user: %v", err)
	}

	return updatedUser, nil
}

// Delete performs a soft delete on a user by setting their deleted_at timestamp.
// Returns an error if the user doesn't exist or deletion fails.
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

// Count returns the total number of non-deleted users in the database.
// Returns the count or an error if the query fails.
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
