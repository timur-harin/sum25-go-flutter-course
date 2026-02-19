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

// Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	err := req.Validate()
	if err != nil {
		return nil, err
	}
	user := req.ToUser()
	query := `INSERT INTO users (name, email) VALUES($1, $2) RETURNING id, created_at, updated_at`
	err = r.db.QueryRow(query, req.Name, req.Email).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, err
}

// GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1`
	var user models.User
	err := user.ScanRow(r.db.QueryRow(query, id))
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1`
	var user models.User
	err := user.ScanRow(r.db.QueryRow(query, email))
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

// Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
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
	now := time.Now()
	args = append(args, now)
	args = append(args, id)

	query := fmt.Sprintf(`UPDATE users SET %s WHERE id = ?`, strings.Join(setClauses, ", "))

	result, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return nil, err
	}
	if rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}

	return r.GetByID(id)
}

// Delete method
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`

	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// Count method
func (r *UserRepository) Count() (int, error) {
	row := r.db.QueryRow("SELECT COUNT(*) FROM users")
	var count int
	err := row.Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
