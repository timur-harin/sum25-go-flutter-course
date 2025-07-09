package repository

import (
	"database/sql"
	"fmt"
	"lab04-backend/models"
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

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	err := req.Validate()
	if err != nil {
		return nil, err
	}
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, name, email, created_at, updated_at
	`
	user := &models.User{
		Name:  req.Name,
		Email: req.Email,
	}
	err = r.db.QueryRow(query, req.Name, req.Email).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, id).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = $1
	`

	user := &models.User{}
	err := r.db.QueryRow(query, email).Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at ASC
	`

	rows, e := r.db.Query(query)
	if e != nil {
		return nil, fmt.Errorf("failed to get all users: %w", e)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}

	if e = rows.Err(); e != nil {
		return nil, fmt.Errorf("rows iteration error: %w", e)
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req.Name == nil && req.Email == nil {
		return nil, fmt.Errorf("no fields to update")
	}
	updatedAt := time.Now()

	query := fmt.Sprintf(`
		UPDATE users
		SET name = $1, email = $2, updated_at = $3
		WHERE id = $4
	`)

	_, err := r.db.Exec(query, req.Name, req.Email, updatedAt, id)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user with id %d not found", id)
		}
		return nil, err
	}

	user, e := r.GetByID(id)
	if e != nil {
		return nil, e
	}
	return user, nil
}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec(`DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user with id %d not found", id)
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
