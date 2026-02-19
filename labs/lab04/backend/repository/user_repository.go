package repository

import (
	"database/sql"
	"fmt"
	"regexp"
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

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// TODO: Create a new user in the database
	// - Validate the request
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps
	if err := req.Validate(); err != nil {
		return nil, err
	}

	user := &models.User{}
	err := r.db.QueryRow(
		"INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, datetime('now'), datetime('now')) RETURNING id, name, email, created_at, updated_at",
		req.Name, req.Email,
	).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return user, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	user := &models.User{}
	row := r.db.QueryRow("SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?", id)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return user, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// TODO: Get user by email from database
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	user := &models.User{}
	row := r.db.QueryRow("SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?", email)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return user, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// TODO: Get all users from database
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly
	rows, err := r.db.Query("SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at")
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %w", err)
	}
	defer rows.Close()

	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, err
	}
	return users, nil
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// TODO: Update user in database
	// - Build dynamic UPDATE query based on non-nil fields in req
	// - Update updated_at timestamp
	// - Return updated user
	// - Handle case where user doesn't exist
	_, err := r.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Build dynamic UPDATE query
	var fields []string
	var args []interface{}

	if req.Name != nil {
		if len(*req.Name) < 2 {
			return nil, fmt.Errorf("name should be at least 2 characters")
		}
		fields = append(fields, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		if len(*req.Email) == 0 {
			return nil, fmt.Errorf("email should not be empty")
		}
		emailCheck := regexp.MustCompile(`^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$`)
		if !emailCheck.MatchString(*req.Email) {
			return nil, fmt.Errorf("email should be valid format")
		}
		fields = append(fields, "email = ?")
		args = append(args, *req.Email)
	}
	if len(fields) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	fields = append(fields, "updated_at = ?")
	args = append(args, time.Now())

	query := "UPDATE users SET " + strings.Join(fields, ", ") + " WHERE id = ?"
	args = append(args, id)

	_, err = r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return r.GetByID(id)
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// TODO: Delete user from database
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	result, err := r.db.Exec("DELETE FROM users WHERE id = ?", id)
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

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	// TODO: Count total number of users
	// - Return count of users in database
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
