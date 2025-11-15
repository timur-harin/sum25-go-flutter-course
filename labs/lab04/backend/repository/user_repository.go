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

// Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// Create a new user in the database
	// - Validate the request
	if err := req.Validate(); err != nil {
		return nil, err
	}
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps
	user := req.ToUser()
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at
	`

	row := r.db.QueryRow(query, user.Name, user.Email, user.CreatedAt, user.UpdatedAt)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}

	return user, nil
}

// Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// Get user by ID from database
	// - Query users table by ID
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	// - Return user or sql.ErrNoRows if not found
	row := r.db.QueryRow(query, id)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, err
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	// - Handle scanning properly
	return user, nil
}

// Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// Get user by email from database
	// - Query users table by email
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = $1
	`
	// - Return user or sql.ErrNoRows if not found
	row := r.db.QueryRow(query, email)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, err
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	// - Handle scanning properly
	return user, nil
}

// Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// Get all users from database
	// - Query all users ordered by created_at
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get users: %w", err)
	}
	// - Return slice of users
	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, fmt.Errorf("failed to scan users: %w", err)
	}
	// - Handle empty result properly
	return users, nil
}

// Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// Update user in database
	// - Build dynamic UPDATE query based on non-nil fields in req
	var updates []string
	var args []interface{}
	argNum := 1

	if req.Name != nil {
		updates = append(updates, fmt.Sprintf("name = $%d", argNum))
		args = append(args, *req.Name)
		argNum++
	}

	if req.Email != nil {
		updates = append(updates, fmt.Sprintf("email = $%d", argNum))
		args = append(args, *req.Email)
		argNum++
	}

	if len(updates) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	// - Update updated_at timestamp
	updates = append(updates, fmt.Sprintf("updated_at = $%d", argNum))
	args = append(args, time.Now())
	argNum++

	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = $%d
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(updates, ", "), argNum)

	row := r.db.QueryRow(query, args...)
	user := &models.User{}
	// - Return updated user
	// - Handle case where user doesn't exist
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found: %w", err)
		}
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return user, nil
}

// Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// Delete user from database
	// - Delete from users table by ID
	query := `
		DELETE FROM users
		WHERE id = $1
	`

	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}
	// - Return error if user doesn't exist
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	// - Consider cascading deletes for posts
	return nil
}

// Implement Count method
func (r *UserRepository) Count() (int, error) {
	// Count total number of users
	query := `
		SELECT COUNT(*) 
		FROM users
	`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	// - Return count of users in database
	return count, nil
}
