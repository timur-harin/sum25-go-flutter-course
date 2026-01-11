package repository

import (
	"database/sql"
	"errors"
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
	if req.Name == "" || req.Email == "" {
		return nil, errors.New("name and email are required")
	}

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES (?, ?, ?, ?)
		RETURNING id, created_at, updated_at
	`

	now := time.Now()
	user := &models.User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}

	err := r.db.QueryRow(query, req.Name, req.Email, now, now).
		Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = ?
	`

	user := &models.User{}
	err := r.db.QueryRow(query, id).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = ?
	`

	user := &models.User{}
	err := r.db.QueryRow(query, email).Scan(
		&user.ID, &user.Name, &user.Email,
		&user.CreatedAt, &user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		ORDER BY created_at
	`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req.Name == nil && req.Email == nil {
		return nil, errors.New("nothing to update")
	}

	var updates []string
	var args []interface{}

	if req.Name != nil {
		updates = append(updates, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		updates = append(updates, "email = ?")
		args = append(args, *req.Email)
	}

	updates = append(updates, "updated_at = ?")
	now := time.Now()
	args = append(args, now)
	args = append(args, id)

	query := fmt.Sprintf("UPDATE users SET %s WHERE id = ?", strings.Join(updates, ", "))

	result, err := r.db.Exec(query, args...)
	if err != nil {
		return nil, err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return nil, err
	}
	if rowsAffected == 0 {
		return nil, sql.ErrNoRows
	}

	// Return updated user
	return r.GetByID(id)
}

func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = ?`

	result, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, err
	}

	return count, nil
}
