package repository

import (
	"database/sql"
	"fmt"

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
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, datetime('now'), datetime('now'))
		RETURNING id, name, email, created_at, updated_at
	`

	var user models.User
	row := r.db.QueryRow(query, req.Name, req.Email)
	err := user.ScanRow(row)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return &user, nil
}

// GetByID gets user by ID from database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	
	var user models.User
	row := r.db.QueryRow(query, id)
	err := user.ScanRow(row)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetByEmail gets user by email from database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	
	var user models.User
	row := r.db.QueryRow(query, email)
	err := user.ScanRow(row)
	if err != nil {
		return nil, err
	}

	return &user, nil
}

// GetAll gets all users from database
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`
	
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %w", err)
	}

	return models.ScanUsers(rows)
}

// Update updates user in database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Check if user exists first
	_, err := r.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Build dynamic update query
	query := `UPDATE users SET updated_at = datetime('now', '+1 second')`
	args := []interface{}{}

	if req.Name != nil {
		query += `, name = ?`
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		query += `, email = ?`
		args = append(args, *req.Email)
	}

	query += ` WHERE id = ?`
	args = append(args, id)

	_, err = r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	// Return updated user
	return r.GetByID(id)
}

// Delete deletes user from database
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get affected rows: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// Count counts total number of users
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}

	return count, nil
}
