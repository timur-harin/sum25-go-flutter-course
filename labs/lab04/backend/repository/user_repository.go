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

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()
	query := `INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?) RETURNING id, name, email, created_at, updated_at`
	row := r.db.QueryRow(query, req.Name, req.Email, now, now)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return &user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	row := r.db.QueryRow(query, id)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	row := r.db.QueryRow(query, email)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to get user: %v", err)
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to query users: %v", err)
	}

	return models.ScanUsers(rows)
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	var setParts []string
	var args []interface{}

	if req.Name != nil {
		setParts = append(setParts, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		setParts = append(setParts, "email = ?")
		args = append(args, *req.Email)
	}

	if len(setParts) == 0 {
		return r.GetByID(id)
	}

	setParts = append(setParts, "updated_at = ?")
	args = append(args, time.Now())
	args = append(args, id)

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at", strings.Join(setParts, ", "))
	row := r.db.QueryRow(query, args...)

	var user models.User
	if err := user.ScanRow(row); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found")
		}
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var count int
	if err := r.db.QueryRow(query).Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}
	return count, nil
}
