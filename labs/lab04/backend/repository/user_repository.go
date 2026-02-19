package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

// UserRepository handles database operations for users
type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create inserts a new user and returns the created user with ID and timestamps
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if req.Name == "" || req.Email == "" {
		return nil, fmt.Errorf("name and email are required")
	}

	now := time.Now()
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at
	`

	user := &models.User{}
	err := r.db.QueryRow(query, req.Name, req.Email, now, now).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("insert user failed: %w", err)
	}

	return user, nil
}

// GetByID returns user by ID or sql.ErrNoRows if not found
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users WHERE id = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

// GetByEmail returns user by email or sql.ErrNoRows if not found
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users WHERE email = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, email).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return user, nil
}

// GetAll returns all users ordered by created_at
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at DESC
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		u := models.User{}
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}

// Update updates non-nil fields of user and returns updated user
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	setClauses := []string{}
	args := []interface{}{}
	argPos := 1

	if req.Name != nil {
		setClauses = append(setClauses, fmt.Sprintf("name = $%d", argPos))
		args = append(args, *req.Name)
		argPos++
	}
	if req.Email != nil {
		setClauses = append(setClauses, fmt.Sprintf("email = $%d", argPos))
		args = append(args, *req.Email)
		argPos++
	}
	if len(setClauses) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	// Always update updated_at with current time
	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argPos))
	args = append(args, time.Now())
	argPos++

	query := fmt.Sprintf(`
		UPDATE users SET %s WHERE id = $%d
		RETURNING id, name, email, created_at, updated_at
	`, strings.Join(setClauses, ", "), argPos)

	args = append(args, id)

	user := &models.User{}
	err := r.db.QueryRow(query, args...).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user with id %d not found", id)
		}
		return nil, err
	}
	return user, nil
}

// Delete removes user by ID, returns error if not found
func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec(`DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return fmt.Errorf("user with id %d not found", id)
	}
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
