package repository

import (
	"context"
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

// Create a new user in the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// Validate the request
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	// Insert into users table with RETURNING clause
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at
	`

	now := time.Now()
	var user models.User
	err := r.db.QueryRowContext(context.Background(), query, req.Name, req.Email, now, now).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return &user, nil
}

// Get user by ID from database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = $1
	`

	var user models.User
	err := r.db.QueryRowContext(context.Background(), query, id).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found with id: %d", id)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

// Get user by email from database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = $1
	`

	var user models.User
	err := r.db.QueryRowContext(context.Background(), query, email).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found with email: %s", email)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

// Get all users from database
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at
	`

	rows, err := r.db.QueryContext(context.Background(), query)
	if err != nil {
		return nil, fmt.Errorf("failed to get users: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return users, nil
}

// Update user in database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Build dynamic UPDATE query based on non-nil fields
	var setParts []string
	var args []interface{}
	argIndex := 1

	if req.Name != nil {
		setParts = append(setParts, fmt.Sprintf("name = $%d", argIndex))
		args = append(args, *req.Name)
		argIndex++
	}

	if req.Email != nil {
		setParts = append(setParts, fmt.Sprintf("email = $%d", argIndex))
		args = append(args, *req.Email)
		argIndex++
	}

	// Always update updated_at
	setParts = append(setParts, fmt.Sprintf("updated_at = $%d", argIndex))
	args = append(args, time.Now())
	argIndex++

	if len(setParts) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	// Add WHERE clause
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = $%d
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(setParts, ", "), argIndex)

	var user models.User
	err := r.db.QueryRowContext(context.Background(), query, args...).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("user not found with id: %d", id)
	}
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return &user, nil
}

// Delete user from database
func (r *UserRepository) Delete(id int) error {
	query := `
		DELETE FROM users
		WHERE id = $1
	`

	result, err := r.db.ExecContext(context.Background(), query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user not found with id: %d", id)
	}

	return nil
}

// Count total number of users
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`

	var count int
	err := r.db.QueryRowContext(context.Background(), query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}

	return count, nil
}
