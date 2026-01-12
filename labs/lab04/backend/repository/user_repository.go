package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	userToCreate := req.ToUser()

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, created_at, updated_at`

	var newUser models.User
	newUser.Name = userToCreate.Name
	newUser.Email = userToCreate.Email

	row := r.db.QueryRow(query, userToCreate.Name, userToCreate.Email, userToCreate.CreatedAt, userToCreate.UpdatedAt)
	err := row.Scan(&newUser.ID, &newUser.CreatedAt, &newUser.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return &newUser, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1"
	row := r.db.QueryRow(query, id)

	var user models.User
	err := user.ScanRow(row) // Using the model's ScanRow method
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, err
		}
		return nil, fmt.Errorf("failed to get user by id: %w", err)
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1"
	row := r.db.QueryRow(query, email)

	var user models.User
	err := user.ScanRow(row)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, err
		}
		return nil, fmt.Errorf("failed to get user by email: %w", err)
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := "SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at DESC"
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all users: %w", err)
	}

	// Using the model's ScanUsers helper function
	users, err := models.ScanUsers(rows)
	if err != nil {
		return nil, fmt.Errorf("failed to scan users: %w", err)
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	var setClauses []string
	var args []interface{}
	argID := 1

	if req.Name != nil {
		setClauses = append(setClauses, fmt.Sprintf("name = $%d", argID))
		args = append(args, *req.Name)
		argID++
	}

	if req.Email != nil {
		setClauses = append(setClauses, fmt.Sprintf("email = $%d", argID))
		args = append(args, *req.Email)
		argID++
	}

	if len(setClauses) == 0 {
		return r.GetByID(id)
	}

	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argID))
	args = append(args, time.Now().UTC())
	argID++

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = $%d RETURNING id, name, email, created_at, updated_at",
		strings.Join(setClauses, ", "), argID)
	args = append(args, id)

	row := r.db.QueryRow(query, args...)
	var updatedUser models.User
	err := updatedUser.ScanRow(row)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, err
		}
		return nil, fmt.Errorf("failed to update user: %w", err)
	}

	return &updatedUser, nil
}

func (r *UserRepository) Delete(id int) error {
	query := "DELETE FROM users WHERE id = $1"
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	var count int
	query := "SELECT COUNT(*) FROM users"
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}
