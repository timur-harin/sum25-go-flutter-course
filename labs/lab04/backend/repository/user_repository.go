package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	user := req.ToUser()

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, ?, ?)
		RETURNING id, name, email, created_at, updated_at
	`

	row := r.db.QueryRowContext(
		context.Background(),
		query,
		user.Name,
		user.Email,
		user.CreatedAt,
		user.UpdatedAt,
	)

	if err := user.ScanRow(row); err != nil {
		if strings.Contains(err.Error(), "UNIQUE constraint failed") {
			return nil, fmt.Errorf("email already exists")
		}
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return user, nil
}

// GetByID gets a user by ID from the database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = ?
	`

	row := r.db.QueryRowContext(context.Background(), query, id)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return user, nil
}

// GetByEmail gets a user by email from the database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = ?
	`

	row := r.db.QueryRowContext(context.Background(), query, email)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return user, nil
}

// GetAll gets all users from the database
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

	return models.ScanUsers(rows)
}

// Update updates a user in the database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Start with base query
	query := `
		UPDATE users
		SET updated_at = ?
	`
	args := []interface{}{time.Now()}

	// Add fields to update if they are not nil
	if req.Name != nil {
		query += ", name = ?"
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		query += ", email = ?"
		args = append(args, *req.Email)
	}

	// Add WHERE clause and RETURNING
	query += " WHERE id = ? RETURNING id, name, email, created_at, updated_at"
	args = append(args, id)

	row := r.db.QueryRowContext(context.Background(), query, args...)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return user, nil
}

// Delete deletes a user from the database
func (r *UserRepository) Delete(id int) error {
	result, err := r.db.ExecContext(context.Background(), "DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

// Count counts the total number of users in the database
func (r *UserRepository) Count() (int, error) {
	var count int
	row := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM users")
	if err := row.Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
