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
	query := `INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id, name, email, created_at, updated_at`
	row := r.db.QueryRow(query, req.Name, req.Email)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	row := r.db.QueryRow(query, id)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	row := r.db.QueryRow(query, email)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, fmt.Errorf("update request is nil")
	}
	fields := []string{}
	args := []interface{}{}
	if req.Name != nil {
		fields = append(fields, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		fields = append(fields, "email = ?")
		args = append(args, *req.Email)
	}
	if len(fields) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}
	updatedAt := time.Now()
	fields = append(fields, "updated_at = ?")
	args = append(args, updatedAt)
	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at",
		strings.Join(fields, ", "))
	args = append(args, id)
	row := r.db.QueryRow(query, args...)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec("DELETE FROM users WHERE id = ?", id)
	if err != nil {
		return err
	}
	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	return count, err
}
