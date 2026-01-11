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
		return nil, fmt.Errorf("validation error: %w", err)
	}

	query := `
		INSERT INTO users (name, email)
		VALUES ($1, $2)
		RETURNING id, name, email, created_at, updated_at
	`

	var user models.User
	err := r.db.QueryRow(query, req.Name, req.Email).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

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
		WHERE id = $1
	`

	var user models.User
	err := r.db.QueryRow(query, id).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
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
		WHERE email = $1
	`

	var user models.User
	err := r.db.QueryRow(query, email).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
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
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows error: %w", err)
	}

	if len(users) == 0 {
		return []models.User{}, nil
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
	var setClauses []string
	var args []interface{}
	argPos := 1

	if req.Name != nil {
		setClauses = append(setClauses, fmt.Sprintf("name = $%d", argPos))
		args = append(args, *req.Name)
		argPos++
	}

	if req.Email != nil {
		setClauses = append(setClauses, fmt.Sprintf("email = $%d", argPos))
		args = append(args, *req.Email)
		argPos++
	}

	if len(setClauses) == 0 {
		return r.GetByID(id)
	}

	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argPos))
	args = append(args, time.Now())
	argPos++

	args = append(args, id)

	query := fmt.Sprintf(`
		UPDATE users
		SET %s
		WHERE id = $%d
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(setClauses, ", "), argPos)

	var user models.User
	err := r.db.QueryRow(query, args...).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if err == sql.ErrNoRows {
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
	if _, err := r.db.Exec("DELETE FROM posts WHERE user_id = $1", id); err != nil {
		return fmt.Errorf("failed to delete user posts: %w", err)
	}

	result, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
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
