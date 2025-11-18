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

// Creates a new user in the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	var user models.User
	if err := req.Validate(); err != nil {
		return nil, err
	}
	query := `INSERT INTO users (name, email, created_at, updated_at)
			  VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
			  RETURNING id, name, email, created_at, updated_at`

	err := r.db.QueryRow(query, strings.TrimSpace(req.Name), strings.TrimSpace(req.Email)).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}
	return &user, nil
}

// Gets user by ID from database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	var user models.User
	if err := r.db.QueryRow(query, id).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by ID: %v", err)
	}
	return &user, nil
}

// Gets user by email from database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	var user models.User
	if err := r.db.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user by email: %v", err)
	}
	return &user, nil
}

// Gets all users from database
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at ASC`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all users: %w", err)
	}
	defer rows.Close()
	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, fmt.Errorf("failed to scan users: %w", err)
	}
	return users, nil
}

// Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
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
	sets = append(sets, "updated_at = STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')")
	args = append(args, id)
	query := fmt.Sprintf(`UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at`, strings.Join(sets, ", "))
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

// Deletes user from database
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check affected rows: %v", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Count total number of users
func (r *UserRepository) Count() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM users`
	if err := r.db.QueryRow(query).Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}
	return count, nil
}
