package repository

import (
	"database/sql"
	"fmt"
	"lab04-backend/models"
	"strings"
	"time"
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

	query := "INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?) RETURNING id, name, email, created_at, updated_at"

	var user models.User

	if err := user.ScanRow(r.db.QueryRow(query, req.Name, req.Email, time.Now(), time.Now())); err != nil {
		return nil, err
	}

	return &user, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?"
	var user models.User

	if err := user.ScanRow(r.db.QueryRow(query, id)); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("no user with id")
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?"
	var user models.User

	if err := user.ScanRow(r.db.QueryRow(query, email)); err != nil {
		return nil, sql.ErrNoRows
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users"
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}

	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, sql.ErrNoRows
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	fields := []string{}
	args := []any{}

	if req.Name != nil {
		fields = append(fields, "name = ?")
		args = append(args, req.Name)
	}

	if req.Email != nil {
		fields = append(fields, "email = ?")
		args = append(args, req.Email)
	}

	fields = append(fields, "updated_at = ?")
	args = append(args, time.Now(), id)

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ?", strings.Join(fields, ", "))

	result, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil || rowsAffected == 0 {
		return nil, fmt.Errorf("user not found")
	}

	return r.GetByID(id)
}

func (r *UserRepository) Delete(id int) error {
	query := "DELETE FROM users WHERE id = ?"

	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil || rowsAffected == 0 {
		return fmt.Errorf("user not found")
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
