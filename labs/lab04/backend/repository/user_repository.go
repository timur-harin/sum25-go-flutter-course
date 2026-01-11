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

// Create inserts a new user into the database and returns it with ID/timestamps populated.
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// validate input
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// build User
	u := req.ToUser()

	// insert and RETURNING generated fields
	row := r.db.QueryRow(
		`INSERT INTO users (name, email, created_at, updated_at)
		 VALUES (?, ?, ?, ?)
		 RETURNING id, name, email, created_at, updated_at`,
		u.Name, u.Email, u.CreatedAt, u.UpdatedAt,
	)

	// scan into u
	if err := u.ScanRow(row); err != nil {
		return nil, err
	}
	return u, nil
}

// GetByID retrieves a single user by its ID (only non-deleted).
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	u := &models.User{}
	row := r.db.QueryRow(
		`SELECT id, name, email, created_at, updated_at
		   FROM users
		  WHERE id = ? AND deleted_at IS NULL`,
		id,
	)
	if err := u.ScanRow(row); err != nil {
		return nil, err
	}
	return u, nil
}

// GetByEmail retrieves a single user by email (only non-deleted).
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	u := &models.User{}
	row := r.db.QueryRow(
		`SELECT id, name, email, created_at, updated_at
		   FROM users
		  WHERE email = ? AND deleted_at IS NULL`,
		email,
	)
	if err := u.ScanRow(row); err != nil {
		return nil, err
	}
	return u, nil
}

// GetAll returns all non-deleted users ordered by creation time.
func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(
		`SELECT id, name, email, created_at, updated_at
		   FROM users
		  WHERE deleted_at IS NULL
	   ORDER BY created_at`,
	)
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

// Update modifies the fields of an existing user and returns the updated record.
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// build dynamic SET clauses
	sets := []string{}
	args := []interface{}{}
	if req.Name != nil {
		sets = append(sets, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		sets = append(sets, "email = ?")
		args = append(args, *req.Email)
	}
	// nothing to update?
	if len(sets) == 0 {
		return r.GetByID(id)
	}

	// always update the updated_at timestamp
	now := time.Now()
	sets = append(sets, "updated_at = ?")
	args = append(args, now)

	// build and execute query
	query := fmt.Sprintf(
		`UPDATE users
		    SET %s
		  WHERE id = ? AND deleted_at IS NULL
		RETURNING id, name, email, created_at, updated_at`,
		strings.Join(sets, ", "),
	)
	args = append(args, id)

	u := &models.User{}
	row := r.db.QueryRow(query, args...)
	if err := u.ScanRow(row); err != nil {
		return nil, err
	}
	return u, nil
}

// Delete performs a soft-delete by setting deleted_at; returns sql.ErrNoRows if none affected.
func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec(
		`UPDATE users
		    SET deleted_at = ?
		  WHERE id = ? AND deleted_at IS NULL`,
		time.Now(), id,
	)
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

// Count returns the total number of non-deleted users.
func (r *UserRepository) Count() (int, error) {
	var cnt int
	row := r.db.QueryRow(
		`SELECT COUNT(*) FROM users WHERE deleted_at IS NULL`,
	)
	if err := row.Scan(&cnt); err != nil {
		return 0, err
	}
	return cnt, nil
}
