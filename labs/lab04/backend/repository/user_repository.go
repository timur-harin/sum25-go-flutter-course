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

// Create creates a new user
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

	row := r.db.QueryRow(
		query,
		user.Name,
		user.Email,
		user.CreatedAt,
		user.UpdatedAt,
	)

	if err := user.ScanRow(row); err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return user, nil
}

// GetByID gets user by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = ?
	`

	row := r.db.QueryRow(query, id)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return user, nil
}

// GetByEmail gets user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = ?
	`

	row := r.db.QueryRow(query, email)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return user, nil
}

// GetAll gets all users
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get users: %v", err)
	}

	return models.ScanUsers(rows)
}

// Update updates a user
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Build dynamic update query
	var setClauses []string
	var args []interface{}
	now := time.Now()

	if req.Name != nil {
		setClauses = append(setClauses, "name = ?")
		args = append(args, *req.Name)
	}

	if req.Email != nil {
		setClauses = append(setClauses, "email = ?")
		args = append(args, *req.Email)
	}

	if len(setClauses) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	setClauses = append(setClauses, "updated_at = ?")
	args = append(args, now)
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = ?
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(setClauses, ", "))

	row := r.db.QueryRow(query, args...)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	return user, nil
}

// Delete deletes a user
func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

// Count counts all users
func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}
	return count, nil
}
