package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users (manual SQL)
type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create creates a new user in the database
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()

	// SQLite doesn't support RETURNING in older versions,
	// so let's do Insert + LastInsertId + select
	// To be safe, do insert then select by last inserted ID:

	tx, err := r.db.Begin()
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()

	result, err := tx.Exec(`INSERT INTO users (name, email, created_at, updated_at) VALUES (?, ?, ?, ?)`,
		strings.TrimSpace(req.Name),
		strings.TrimSpace(req.Email),
		now,
		now,
	)
	if err != nil {
		return nil, err
	}

	lastID, err := result.LastInsertId()
	if err != nil {
		return nil, err
	}

	user := &models.User{}
	err = tx.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`, lastID).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}

	if err := tx.Commit(); err != nil {
		return nil, err
	}

	return user, nil
}

// GetByID returns user by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	user := &models.User{}
	err := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE id = ?`, id).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, sql.ErrNoRows
		}
		return nil, err
	}

	return user, nil
}

// GetByEmail returns user by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	user := &models.User{}
	err := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE email = ?`, email).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, sql.ErrNoRows
		}
		return nil, err
	}

	return user, nil
}

// GetAll returns all users ordered by created_at
func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var u models.User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

// Update updates a user by ID
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil {
		return nil, errors.New("update request is nil")
	}

	var sets []string
	var args []interface{}

	if req.Name != nil {
		name := strings.TrimSpace(*req.Name)
		if len(name) < 2 {
			return nil, errors.New("name must be at least 2 characters")
		}
		sets = append(sets, "name = ?")
		args = append(args, name)
	}

	if req.Email != nil {
		email := strings.TrimSpace(*req.Email)
		if email == "" {
			return nil, errors.New("email cannot be empty")
		}
		sets = append(sets, "email = ?")
		args = append(args, email)
	}

	if len(sets) == 0 {
		return nil, errors.New("no fields to update")
	}

	// Always update updated_at
	sets = append(sets, "updated_at = ?")
	args = append(args, time.Now())

	args = append(args, id)

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ?", strings.Join(sets, ", "))

	res, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return nil, err
	}

	if rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}

	return r.GetByID(id)
}

// Delete removes a user by ID
func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
	if err != nil {
		return err
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return err
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	// TODO: Consider cascading deletes for posts if needed

	return nil
}

// Count returns total number of users
func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
