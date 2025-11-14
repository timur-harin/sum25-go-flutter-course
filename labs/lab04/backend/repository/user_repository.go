package repository

import (
	"database/sql"
	"fmt"
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

// Creates a user in the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {

	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `INSERT INTO users (name, email, created_at, updated_at)
			  VALUES (?, ?, datetime('now'), datetime('now'))`

	result, err := r.db.Exec(query, req.Name, req.Email)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, fmt.Errorf("failed to get last insert id: %v", err)
	}

	return r.GetByID(int(id))
}

// Gets a user by ID from the database
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`
	var user models.User
	if err := r.db.QueryRow(query, id).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found: %d", id)
		}
		return nil, fmt.Errorf("failed to get user by ID: %v", err)
	}
	return &user, nil
}

// Gets a user by email from the database
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`

	var user models.User

	if err := r.db.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user not found: %s", email)
		}
		return nil, fmt.Errorf("failed to get user by email: %v", err)
	}

	return &user, nil
}

// Returns all users from the database
func (r *UserRepository) GetAll() ([]models.User, error) {

	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at DESC`

	var users []models.User
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all users: %v", err)
	}
	defer rows.Close()

	for rows.Next() {
		var user models.User
		if err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan user: %v", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("failed to iterate users: %v", err)
	}

	return users, nil
}

// Updates a user in the database
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	query := `UPDATE users SET updated_at = datetime('now')`

	var args []interface{}
	if req.Name != nil {
		query += `, name = ?`
		args = append(args, req.Name)
	}
	if req.Email != nil {
		query += `, email = ?`
		args = append(args, req.Email)
	}
	query += ` WHERE id = ? RETURNING id, name, email, created_at, updated_at`
	args = append(args, id)

	var user models.User
	if err := user.ScanRow(r.db.QueryRow(query, args...)); err != nil {
		return nil, fmt.Errorf("failed to update user: %v", err)
	}

	user.UpdatedAt = time.Now()

	return &user, nil
}

// Deletes a user from the database
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %v", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %v", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("no user found with ID: %d", id)
	}

	return nil
}

// Counts users in the database
func (r *UserRepository) Count() (int, error) {
	var count int
	query := `SELECT COUNT(*) FROM users`
	if err := r.db.QueryRow(query).Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count users: %v", err)
	}

	return count, nil
}
