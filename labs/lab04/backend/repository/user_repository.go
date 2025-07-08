package repository

import (
	"database/sql"
	"fmt"

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

// Create inserts a new user into the database and returns the created user
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
	result, err := r.db.Exec(query, req.Name, req.Email)
	if err != nil {
		return nil, err
	}
	id, err := result.LastInsertId()
	if err != nil {
		return nil, err
	}
	return r.GetByID(int(id))
}

// GetByID retrieves a user by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ? AND deleted_at IS NULL`
	row := r.db.QueryRow(query, id)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

// GetByEmail retrieves a user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ? AND deleted_at IS NULL`
	row := r.db.QueryRow(query, email)
	var user models.User
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return &user, nil
}

// GetAll retrieves all users ordered by created_at
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE deleted_at IS NULL ORDER BY created_at`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

// Update updates a user in the database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil || (req.Name == nil && req.Email == nil) {
		return nil, fmt.Errorf("no fields to update")
	}

	setClauses := []string{}
	args := []interface{}{}
	if req.Name != nil {
		setClauses = append(setClauses, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		setClauses = append(setClauses, "email = ?")
		args = append(args, *req.Email)
	}
	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")
	query := "UPDATE users SET " + joinClauses(setClauses, ", ") + " WHERE id = ? AND deleted_at IS NULL"
	args = append(args, id)
	result, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}
	n, err := result.RowsAffected()
	if err != nil {
		return nil, err
	}
	if n == 0 {
		return nil, sql.ErrNoRows
	}
	return r.GetByID(id)
}

// joinClauses is a helper for building SQL SET clauses
func joinClauses(clauses []string, sep string) string {
	if len(clauses) == 0 {
		return ""
	}
	result := clauses[0]
	for i := 1; i < len(clauses); i++ {
		result += sep + clauses[i]
	}
	return result
}

// Delete performs a soft delete on a user (sets deleted_at)
func (r *UserRepository) Delete(id int) error {
	query := `UPDATE users SET deleted_at = CURRENT_TIMESTAMP WHERE id = ? AND deleted_at IS NULL`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	n, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Count returns the total number of users (excluding soft-deleted)
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
