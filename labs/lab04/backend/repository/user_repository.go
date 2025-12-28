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
	// Validate the request
	if err := req.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()
	res, err := r.db.Exec(
		"INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?)",
		req.Name, req.Email, now, now,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to insert user: %w", err)
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, fmt.Errorf("failed to retrieve last insert id: %w", err)
	}

	return &models.User{
		ID:        int(id),
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	if id <= 0 {
		return nil, fmt.Errorf("invalid user ID: %d", id)
	}

	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?"

	row := r.db.QueryRow(query, id)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		return nil, sql.ErrNoRows
	}

	return user, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	if email == "" {
		return nil, fmt.Errorf("email cannot be empty")
	}

	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?"
	row := r.db.QueryRow(query, email)
	user := &models.User{}
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return user, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at"
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %w", err)
	}
	return models.ScanUsers(rows)
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if id <= 0 {
		return nil, fmt.Errorf("invalid user ID")
	}

	query := "UPDATE users SET "
	args := []interface{}{}
	updates := []string{}

	if req.Name != nil {
		updates = append(updates, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		updates = append(updates, "email = ?")
		args = append(args, *req.Email)
	}

	if len(updates) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	updates = append(updates, "updated_at = ?")
	now := time.Now()
	args = append(args, now)
	query += fmt.Sprintf("%s WHERE id = ?", strings.Join(updates, ", "))
	args = append(args, id)

	res, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update user: %w", err)
	}
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return nil, fmt.Errorf("failed to get affected rows: %w", err)
	}
	if rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}
	return r.GetByID(id)
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	if id <= 0 {
		return fmt.Errorf("invalid user ID")
	}
	res, err := r.db.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
