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

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if req.Name == "" || req.Email == "" {
		return nil, fmt.Errorf("name and email are required")
	}

	var user models.User
	query := `INSERT INTO users (name, email) VALUES ($1, $2) 
	          RETURNING id, name, email, created_at, updated_at`
	err := r.db.QueryRow(query, req.Name, req.Email).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	return &user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	var user models.User
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1`
	err := r.db.QueryRow(query, id).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1`
	err := r.db.QueryRow(query, email).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get user: %w", err)
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, fmt.Errorf("failed to get users: %w", err)
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows error: %w", err)
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
    // Проверяем, есть ли что обновлять
    if req.Name == nil && req.Email == nil {
        return r.GetByID(id)
    }

    // Сначала получаем текущего пользователя
    currentUser, err := r.GetByID(id)
    if err != nil {
        return nil, err
    }

    var setParts []string
    var args []interface{}
    argPos := 1

    if req.Name != nil {
        setParts = append(setParts, fmt.Sprintf("name = $%d", argPos))
        args = append(args, *req.Name)
        argPos++
    }

    if req.Email != nil {
        setParts = append(setParts, fmt.Sprintf("email = $%d", argPos))
        args = append(args, *req.Email)
        argPos++
    }

    // Явно устанавливаем updated_at как текущее время
    setParts = append(setParts, fmt.Sprintf("updated_at = $%d", argPos))
    args = append(args, time.Now()) // Используем текущее время
    argPos++

    query := fmt.Sprintf(
        "UPDATE users SET %s WHERE id = $%d RETURNING id, name, email, created_at, updated_at",
        strings.Join(setParts, ", "),
        argPos,
    )
    args = append(args, id)

    var user models.User
    err = r.db.QueryRow(query, args...).Scan(
        &user.ID,
        &user.Name,
        &user.Email,
        &user.CreatedAt,
        &user.UpdatedAt,
    )
    if err != nil {
        return nil, fmt.Errorf("failed to update user: %w", err)
    }

    // Дополнительная проверка, что updated_at действительно обновился
    if !user.UpdatedAt.After(currentUser.UpdatedAt) {
        return nil, fmt.Errorf("updated_at was not properly updated")
    }

    return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec("DELETE FROM users WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count users: %w", err)
	}
	return count, nil
}