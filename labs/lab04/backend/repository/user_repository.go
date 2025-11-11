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

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	user := req.ToUser()
	row := r.db.QueryRow(
		`
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at
		`,
		user.Name, user.Email, user.CreatedAt, user.UpdatedAt,
	)
	if err := user.ScanRow(row); err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	user := &models.User{}
	row := r.db.QueryRow(`
		SELECT id, name, email, created_at, updated_at FROM users
		WHERE id = $1
	`, id)
	if err := user.ScanRow(row); err != nil {
		return nil, sql.ErrNoRows
	}
	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	user := &models.User{}
	row := r.db.QueryRow(`
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = $1
	`, email)
	if err := user.ScanRow(row); err != nil {
		return nil, sql.ErrNoRows
	}
	return user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`
		SELECT id, name, email, created_at, updated_at
		FROM users
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, err
	}

	if users == nil {
		return []models.User{}, nil
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	args := []any{}
	query := "UPDATE users SET "
	setClauses := []string{}

	if req.Name != nil && *req.Name != "" {
		setClauses = append(setClauses, fmt.Sprintf("name = $%d", len(args)+1))
		args = append(args, *req.Name)
	}
	if req.Email != nil && *req.Email != "" {
		setClauses = append(setClauses, fmt.Sprintf("email = $%d", len(args)+1))
		args = append(args, *req.Email)
	}

	if len(setClauses) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	// Add updated_at field
	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", len(args)+1))
	args = append(args, time.Now())

	query += fmt.Sprintf("%s WHERE id = $%d RETURNING id, name, email, created_at, updated_at",
	                     joinStrings(setClauses, ", "), len(args)+1)
	args = append(args, id)

	user := models.User{}
	err := r.db.QueryRow(query, args...).Scan(
		&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user with id %d not found", id)
		}
		return nil, err
	}

	return &user, nil
}

func joinStrings(strs []string, sep string) string {
	result := ""
	for i, s := range strs {
		if i > 0 {
			result += sep
		}
		result += s
	}
	return result
}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
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

func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
