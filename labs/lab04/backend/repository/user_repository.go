package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users
// This repository demonstrates MANUAL SQL approach with database/sql package
var (
	ErrInvalidName  = errors.New("name must be at least 2 characters")
	ErrInvalidEmail = errors.New("email must be a valid format")
	ErrNoRows       = sql.ErrNoRows
	emailRegex      = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
)

type UserRepo struct {
	ID        int        `json:"id" db:"id"`
	Name      string     `json:"name" db:"name"`
	Email     string     `json:"email" db:"email"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
	DeletedAt *time.Time `json:"deleted_at,omitempty" db:"deleted_at"`
}

type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*UserRepo, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	if err := validation(req.Name, req.Email); err != nil {
		return nil, err
	}
	query := `INSERT INTO users (name, email, created_at, updated_at)
	VALUES ($1, $2, $3, $4)
	RETURNING id, created_at, updated_at, deleted_at`
	now := time.Now().UTC()
	row := r.db.QueryRow(query, req.Name, req.Email, now, now)
	user := &UserRepo{Name: req.Name, Email: req.Email}
	err := row.Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt, &user.DeletedAt)
	if err != nil {
		return nil, fmt.Errorf("Create user: %w", err)
	}
	return user, nil
}
func validation(name, email string) error {
	if len(name) < 2 {
		return ErrInvalidName
	}
	if !emailRegex.MatchString(email) {
		return ErrInvalidEmail
	}
	return nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*UserRepo, error) {
	query := `SELECT id, name, email, created_at, updated_at, deleted_at
	FROM users WHERE id = $1 AND deleted_at IS NULL`
	user := &UserRepo{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("GetByID: %w", err)
	}
	return user, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*UserRepo, error) {
	if !emailRegex.MatchString(email) {
		return nil, ErrInvalidEmail
	}
	query := `SELECT id, name, email, created_at, updated_at, deleted_at
	FROM users WHERE email = $1 AND deleted_at IS NULL`
	user := &UserRepo{}
	err := r.db.QueryRow(query, email).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("GetByEmail: %w", err)
	}
	return user, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]UserRepo, error) {
	query := `SELECT id, name, email, created_at, updated_at, deleted_at
	FROM users WHERE deleted_at IS NULL ORDER BY created_at`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("GetAll: %w", err)
	}
	defer rows.Close()

	var users []UserRepo
	for rows.Next() {
		var u UserRepo
		if err := rows.Scan(
			&u.ID, &u.Name, &u.Email,
			&u.CreatedAt, &u.UpdatedAt, &u.DeletedAt,
		); err != nil {
			return nil, fmt.Errorf("scan GetAll: %w", err)
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("GetAll rows: %w", err)
	}
	return users, nil
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*UserRepo, error) {
	var sets []string
	var args []interface{}
	pos := 1

	if req.Name != nil {
		if len(*req.Name) < 2 {
			return nil, ErrInvalidName
		}
		sets = append(sets, fmt.Sprintf("name = $%d", pos))
		args = append(args, *req.Name)
		pos++
	}
	if req.Email != nil {
		if !emailRegex.MatchString(*req.Email) {
			return nil, ErrInvalidEmail
		}
		sets = append(sets, fmt.Sprintf("email = $%d", pos))
		args = append(args, *req.Email)
		pos++
	}
	sets = append(sets, fmt.Sprintf("updated_at = $%d", pos))
	now := time.Now().UTC()
	args = append(args, now)
	pos++

	if len(sets) == 0 {
		return r.GetByID(id)
	}
	query := fmt.Sprintf("UPDATE users SET %s WHERE id = $%d AND deleted_at IS NULL RETURNING id, name, email, created_at, updated_at, deleted_at",
		strings.Join(sets, ", "), pos)
	args = append(args, id)

	row := r.db.QueryRow(query, args...)
	user := &UserRepo{}
	err := row.Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt, &user.DeletedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, ErrNoRows
	}
	if err != nil {
		return nil, fmt.Errorf("Update: %w", err)
	}
	return user, nil
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// TODO: Delete user from database
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	now := time.Now().UTC()
	res, err := r.db.Exec("UPDATE users SET deleted_at = $1, updated_at = $2 WHERE id = $3 AND deleted_at IS NULL", now, now, id)
	if err != nil {
		return fmt.Errorf("Delete: %w", err)
	}
	count, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("Delete RowsAffected: %w", err)
	}
	if count == 0 {
		return ErrNoRows
	}
	return nil
}

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	// TODO: Count total number of users
	// - Return count of users in database
	var cnt int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users WHERE deleted_at IS NULL").Scan(&cnt)
	if err != nil {
		return 0, fmt.Errorf("Count: %w", err)
	}
	return cnt, nil
}
