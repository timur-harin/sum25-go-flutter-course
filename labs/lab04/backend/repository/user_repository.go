package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create inserts a new user and returns the created user
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()
	query := `
	INSERT INTO users (name, email, created_at, updated_at)
	VALUES (?, ?, ?, ?)
	RETURNING id, name, email, created_at, updated_at
	`

	row := r.db.QueryRow(query, req.Name, req.Email, now, now)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

// GetByID fetches a user by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
	SELECT id, name, email, created_at, updated_at
	FROM users WHERE id = ?
	`
	var user models.User
	row := r.db.QueryRow(query, id)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

// GetByEmail fetches a user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
	SELECT id, name, email, created_at, updated_at
	FROM users WHERE email = ?
	`
	var user models.User
	row := r.db.QueryRow(query, email)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

// GetAll retrieves all users
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
	SELECT id, name, email, created_at, updated_at
	FROM users
	ORDER BY created_at ASC
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

// Update modifies user fields that are not nil
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	var fields []string
	var args []interface{}

	if req.Name != nil {
		fields = append(fields, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		fields = append(fields, "email = ?")
		args = append(args, *req.Email)
	}
	if len(fields) == 0 {
		return nil, errors.New("no fields to update")
	}

	fields = append(fields, "updated_at = ?")
	args = append(args, time.Now())
	args = append(args, id)

	query := fmt.Sprintf(`
	UPDATE users
	SET %s
	WHERE id = ?
	`, strings.Join(fields, ", "))

	res, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil || rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}

	return r.GetByID(id)
}

// Delete removes a user by ID
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	res, err := r.db.Exec(query, id)
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

// Count returns the total number of users
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}
