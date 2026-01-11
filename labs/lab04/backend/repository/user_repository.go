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

func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at`
	validateErr := req.Validate()
	if validateErr == nil {
		var user models.User
		err := r.db.QueryRow(query, req.Name, req.Email, time.Now(), time.Now()).Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		return &user, nil
	}
	return nil, validateErr
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE id = $1`
	var user models.User
	err := r.db.QueryRow(query, id).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM users
		WHERE email = $1`
	var user models.User
	err := r.db.QueryRow(query, email).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `
		SELECT id, name, email, created_at, updated_at
		FROM USERS
		ORDER BY created_at ASC`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var users []models.User
	for rows.Next() {
		var user models.User
		err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	query := `
		UPDATE users
		SET `

	paramIndex := 0
	involvedParams := []interface{}{}

	if req.Name != nil {
		paramIndex++
		query += fmt.Sprintf(`name = $%d, `, paramIndex)
		involvedParams = append(involvedParams, req.Name)
	}
	if req.Email != nil {
		paramIndex++
		query += fmt.Sprintf(`email = $%d, `, paramIndex)
		involvedParams = append(involvedParams, req.Email)
	}
	involvedParams = append(involvedParams, time.Now())
	involvedParams = append(involvedParams, id)
	query += fmt.Sprintf(`updated_at = $%d WHERE id = $%d RETURNING id, name, email, created_at, updated_at`, paramIndex+1, paramIndex+2)
	var user models.User
	err := r.db.QueryRow(query, involvedParams...).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) Delete(id int) error {
	query := `
		DELETE FROM users WHERE id = $1`
	res, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}
	affectedRows, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affectedRows == 0 {
		return sql.ErrNoRows
	}
	return nil
}

func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var totalNumber int
	err := r.db.QueryRow(query).Scan(&totalNumber)
	if err != nil {
		return 0, err
	}
	return totalNumber, nil
}
