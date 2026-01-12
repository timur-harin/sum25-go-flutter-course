package repository

import (
	"context"
	"database/sql"
	"fmt"

	"errors"
	"lab04-backend/models"

	//"os"
	"time"
)

type User struct {
	ID           int        `json:"id"`
	Name         string     `json:"name"`
	Email        string     `json:"email"`
	PasswordHash string     `json:"password_hash"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
	DeletedAt    *time.Time `json:"deleted_at"` // Nullable
}

type CreateUserRequest struct {
	Name         string `json:"name"`
	Email        string `json:"email"`
	PasswordHash string `json:"password_hash"`
}

func (r *CreateUserRequest) Validate() error {
	if len(r.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if len(r.Email) < 5 || !containsAt(r.Email) {
		return errors.New("invalid email")
	}
	if len(r.PasswordHash) < 8 {
		return errors.New("password hash too short")
	}
	return nil
}

// ========== UpdateUserRequest ==========
type UpdateUserRequest struct {
	Name         string `json:"name"`
	Email        string `json:"email"`
	PasswordHash string `json:"password_hash"`
}

func (r *UpdateUserRequest) Validate() error {
	if len(r.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if len(r.Email) < 5 || !containsAt(r.Email) {
		return errors.New("invalid email")
	}
	if len(r.PasswordHash) < 8 {
		return errors.New("password hash too short")
	}
	return nil
}

// ========== Helper function ==========
func containsAt(email string) bool {
	for _, c := range email {
		if c == '@' {
			return true
		}
	}
	return false
}

// UserRepository handles database operations for users
// This repository demonstrates MANUAL SQL approach with database/sql package
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create inserts a new user into the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	query := `INSERT INTO users (name, email, password_hash)
	          VALUES ($1, $2, $3)
	          RETURNING id, name, email, password_hash, created_at, updated_at, deleted_at`
	user := new(models.User)
	err := r.db.QueryRowContext(context.Background(), query,
		req.Name, req.Email, req.PasswordHash,
	).Scan(&user.ID, &user.Name, &user.Email, &user.PasswordHash, &user.CreatedAt, &user.UpdatedAt, &user.DeletedAt)
	return user, err
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, password_hash, created_at, updated_at, deleted_at FROM users WHERE id = $1`
	user := new(models.User)
	err := r.db.QueryRowContext(context.Background(), query, id).
		Scan(&user.ID, &user.Name, &user.Email, &user.PasswordHash, &user.CreatedAt, &user.UpdatedAt, &user.DeletedAt)
	return user, err
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, password_hash, created_at, updated_at, deleted_at FROM users WHERE email = $1`
	user := new(models.User)
	err := r.db.QueryRowContext(context.Background(), query, email).
		Scan(&user.ID, &user.Name, &user.Email, &user.PasswordHash, &user.CreatedAt, &user.UpdatedAt, &user.DeletedAt)
	return user, err
}

// GetAll retrieves all users
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, password_hash, created_at, updated_at, deleted_at FROM users ORDER BY created_at ASC`
	rows, err := r.db.QueryContext(context.Background(), query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.PasswordHash, &user.CreatedAt, &user.UpdatedAt, &user.DeletedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}

// Update updates a user by ID
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	updatedAt := time.Now()

	query := `
		UPDATE users
		SET name = ?, email = ?, password_hash = ?, updated_at = ?
		WHERE id = ?
	`

	_, err := r.db.Exec(query, req.Name, req.Email, req.PasswordHash, updatedAt, id)
	if err != nil {
		return nil, err
	}

	// Get updated user
	user, err := r.GetByID(id)
	if err != nil {
		return nil, err
	}

	// Overwrite to ensure it's consistent
	user.UpdatedAt = updatedAt

	return user, nil
}

// Delete deletes a user by ID
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = $1`
	res, err := r.db.ExecContext(context.Background(), query, id)
	if err != nil {
		return err
	}
	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return fmt.Errorf("user not found")
	}
	return nil
}

// Count returns the total number of users
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var count int
	err := r.db.QueryRowContext(context.Background(), query).Scan(&count)
	return count, err
}
