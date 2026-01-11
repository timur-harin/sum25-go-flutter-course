package repository

import (
	"database/sql"
	"errors"
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

	// SQLite uses ? placeholders, not $1, $2
	result, err := r.db.Exec(`INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
		req.Name, req.Email)
	if err != nil {
		return nil, err
	}
	
	id, err := result.LastInsertId()
	if err != nil {
		return nil, err
	}
	
	return r.GetByID(int(id))
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// SQLite uses ? placeholders, not $1
	row := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE id = ? AND deleted_at IS NULL`, id)

	var user models.User

	if err := user.ScanRow(row); err != nil {
		return nil, err
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// SQLite uses ? placeholders, not $1
	row := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE email = ? AND deleted_at IS NULL`, email)

	var user models.User

	if err := user.ScanRow(row); err != nil {
		return nil, err
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`SELECT id, name, email, created_at, updated_at FROM users WHERE deleted_at IS NULL ORDER BY created_at`)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil || (req.Email == nil && req.Name == nil) {
		return nil, errors.New("no fields to update")
	}
	
	var setClauses []string
	var args []interface{}

	if req.Name != nil {
		setClauses = append(setClauses, "name = ?")
		args = append(args, *req.Name)
	}

	if req.Email != nil {
		setClauses = append(setClauses, "email = ?")
		args = append(args, *req.Email)
	}
	
	setClauses = append(setClauses, "updated_at = ?")
	args = append(args, time.Now())
	
	// Add ID for WHERE clause
	args = append(args, id)
	
	query := fmt.Sprintf(`UPDATE users SET %s WHERE deleted_at IS NULL AND id = ? RETURNING id, name, email, created_at, updated_at`, strings.Join(setClauses, ", "))
	
	row := r.db.QueryRow(query, args...)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user with id %d not found", id)
		}
		return nil, err
	}

	return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
	if err != nil {
		return errors.New("failed to delete the user by id")
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return errors.New("failed to get rows affected")
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user with id %d was not found", id)
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
