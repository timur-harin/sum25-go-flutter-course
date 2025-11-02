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

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// TODO: Create a new user in the database
	// - Validate the request
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	user := req.ToUser()
	query := `INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?) RETURNING id, created_at, updated_at`
	row := r.db.QueryRow(query, user.Name, user.Email, user.CreatedAt, user.UpdatedAt)

	var id int
	var createdAt, updatedAt time.Time
	err := row.Scan(&id, &createdAt, &updatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to scan returned user data: %w", err)
	}

	user.ID = id
	user.CreatedAt = createdAt
	user.UpdatedAt = updatedAt

	return user, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	row := r.db.QueryRow(query, id)

	var user models.User
	err := user.ScanRow(row)
	if err != nil {
		return nil, fmt.Errorf("failed to get user by ID %d: %w", id, err)
	}

	return &user, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// TODO: Get user by email from database
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	row := r.db.QueryRow(query, email)

	var user models.User
	err := user.ScanRow(row)
	if err != nil {
		return nil, fmt.Errorf("failed to get user by email %s: %w", email, err)
	}

	return &user, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// TODO: Get all users from database
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at DESC`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query all users: %w", err)
	}

	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, fmt.Errorf("failed to scan users: %w", err)
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
	sets := []string{}
	args := []interface{}{}

	if req.Name != nil {
		sets = append(sets, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		sets = append(sets, "email = ?")
		args = append(args, *req.Email)
	}

	if len(sets) == 0 {
		// No fields to update, return the existing user
		return r.GetByID(id)
	}

	sets = append(sets, "updated_at = ?")
	args = append(args, time.Now())
	args = append(args, id) // Add ID for WHERE clause

	query := fmt.Sprintf(`UPDATE users SET %s WHERE id = ?`, strings.Join(sets, ", "))

	res, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user with ID %d: %w", id, err)
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return nil, fmt.Errorf("failed to get rows affected for update: %w", err)
	}
	if rowsAffected == 0 {
		return nil, fmt.Errorf("user with ID %d not found for update", id) // Or a specific ErrNotFound
	}

	return r.GetByID(id) // Fetch and return the updated user
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// TODO: Delete user from database
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	query := `DELETE FROM users WHERE id = ?`
	res, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user with ID %d: %w", id, err)
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected for delete: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("user with ID %d not found for deletion", id) // Or a specific ErrNotFound
	}

	return nil
}

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	// TODO: Count total number of users
	// - Return count of users in database
	query := `SELECT COUNT(*) FROM users`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
