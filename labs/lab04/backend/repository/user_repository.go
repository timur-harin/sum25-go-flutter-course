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
	user := req.ToUser()
	query := `INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?) RETURNING id, created_at, updated_at`
	row := r.db.QueryRow(query, user.Name, user.Email, user.CreatedAt, user.UpdatedAt)
	err := row.Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	row := r.db.QueryRow(query, id)
	var user models.User
	err := user.ScanRow(row)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`
	row := r.db.QueryRow(query, email)
	var user models.User
	err := user.ScanRow(row)
	if err != nil {
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
	set := []string{}
	args := []interface{}{}
	if req.Name != nil {
		set = append(set, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		set = append(set, "email = ?")
		args = append(args, *req.Email)
	}
	if len(set) == 0 {
		return r.GetByID(id)
	}
	set = append(set, "updated_at = ?")
	now := sql.NullTime{Time: time.Now().UTC(), Valid: true}
	args = append(args, now.Time, id)
	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ? RETURNING id, name, email, created_at, updated_at", strings.Join(set, ", "))
	row := r.db.QueryRow(query, args...)
	var user models.User
	err := row.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	res, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	n, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return sql.ErrNoRows
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
