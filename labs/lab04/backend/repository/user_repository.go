package repository

import (
	"database/sql"
	"errors"
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
	// - Validate the request
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps

	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := "INSERT INTO users (name, email) VALUES (?, ?) RETURNING id, created_at, updated_at"
	var id int
	var createdAt, updatedAt time.Time

	if err := r.db.QueryRow(query, req.Name, req.Email).Scan(&id, &createdAt, &updatedAt); err != nil {
		return nil, err
	}

	return &models.User{
		ID:        id,
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
	}, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly

	u := &models.User{}
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE id=?"

	if err := r.db.QueryRow(query, id).Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	); err != nil {
		return nil, err
	}
	return u, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly

	u := &models.User{}
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE email=?"

	if err := r.db.QueryRow(query, email).Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	); err != nil {
		return nil, err
	}
	return u, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly

	users := make([]models.User, 0)
	rows, err := r.db.Query("SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		u := &models.User{}
		if err = rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		); err != nil {
			return nil, err
		}
		users = append(users, *u)
	}
	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// - Build dynamic UPDATE query based on non-nil fields in req
	// - Update updated_at timestamp
	// - Return updated user
	// - Handle case where user doesn't exist
	var (
		set  []string
		args []interface{}
	)

	if req.Name != nil {
		set = append(set, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		set = append(set, "email = ?")
		args = append(args, *req.Email)
	}
	if len(set) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	set = append(set, "updated_at = ?")
	args = append(args, time.Now())

	query := fmt.Sprintf(`UPDATE users SET %s WHERE id = ?
                          RETURNING id, name, email, created_at, updated_at`,
		strings.Join(set, ", "))
	args = append(args, id)

	var u models.User
	if err := r.db.QueryRow(query, args...).
		Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("user %d not found", id)
		}
		return nil, err
	}
	return &u, nil
}

func (r *UserRepository) Delete(id int) error {
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	res, err := r.db.Exec(`DELETE FROM users WHERE id = ?`, id)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return fmt.Errorf("user %d not found", id)
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	// - Return count of users in database
	var cnt int
	if err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&cnt); err != nil {
		return 0, err
	}
	return cnt, nil
}
