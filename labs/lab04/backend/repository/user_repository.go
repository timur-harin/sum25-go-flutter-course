package repository

import (
	"database/sql"
	"fmt"

	"lab04-backend/models"

	"errors"
	"strings"
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
	// Validate
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, name, email, created_at, updated_at
	`

	var user models.User
	err := r.db.QueryRow(query, strings.TrimSpace(req.Name), strings.TrimSpace(req.Email)).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return &user, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = ?
	`

	var user models.User
	err := r.db.QueryRow(query, id).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by ID: %w", err)
	}

	return &user, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// TODO: Get user by email from database
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = ?
	`

	var user models.User
	err := r.db.QueryRow(query, strings.TrimSpace(email)).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}

	return &user, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// TODO: Get all users from database
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at ASC
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %w", err)
	}
	defer rows.Close()

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
	if req == nil {
		return nil, errors.New("update request cannot be nil")
	}

	var sets []string
	var args []interface{}

	if req.Name != nil {
		sets = append(sets, "name = ?")
		args = append(args, strings.TrimSpace(*req.Name))
	}
	if req.Email != nil {
		sets = append(sets, "email = ?")
		args = append(args, strings.TrimSpace(*req.Email))
	}

	if len(sets) == 0 {
		return nil, errors.New("no fields to update")
	}

	// Always update updated_at
	sets = append(sets, "updated_at = STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')")
	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = ?
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(sets, ", "))

	var user models.User
	err := r.db.QueryRow(query, args...).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return &user, nil
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// TODO: Delete user from database
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	query := `
		DELETE FROM users
		WHERE id = ?
	`

	res, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	affected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get affected rows: %w", err)
	}

	if affected == 0 {
		return sql.ErrNoRows
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
