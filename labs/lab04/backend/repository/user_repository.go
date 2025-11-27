package repository

import (
	"database/sql"
	"fmt"
	"time"

	"lab04-backend/models"
)

type UserRepository struct {
	db *sql.DB
}

// NewUserRepository creates a new UserRepository with the given database connection
func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

// Create inserts a new user into the database and returns the created user
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `
		INSERT INTO users (name, email, created_at, updated_at)
		VALUES ($1, $2, $3, $4)
		RETURNING id, name, email, created_at, updated_at
	`
	now := time.Now()
	user := &models.User{}

	err := r.db.QueryRow(query, req.Name, req.Email, now, now).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}

	return user, nil
}

// GetByID retrieves a user by their ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1`

	user := &models.User{}
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

	return user, nil
}

// GetByEmail retrieves a user by their email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1`

	user := &models.User{}
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

	return user, nil
}

// GetAll returns all users ordered by creation time
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at`

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []models.User
	for rows.Next() {
		var user models.User
		if err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	return users, nil
}

// Update modifies an existing user based on non-nil fields in req and returns the updated user
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	query := `UPDATE users SET `
	params := []interface{}{}
	paramID := 1

	if req.Name != nil {
		query += fmt.Sprintf("name = $%d,", paramID)
		params = append(params, *req.Name)
		paramID++
	}

	if req.Email != nil {
		query += fmt.Sprintf("email = $%d,", paramID)
		params = append(params, *req.Email)
		paramID++
	}

	query += fmt.Sprintf("updated_at = $%d WHERE id = $%d RETURNING id, name, email, created_at, updated_at", paramID, paramID+1)
	now := time.Now()
	params = append(params, now, id)

	user := &models.User{}
	err := r.db.QueryRow(query, params...).Scan(
		&user.ID,
		&user.Name,
		&user.Email,
		&user.CreatedAt,
		&user.UpdatedAt,
	)
	if err != nil {
		return nil, err
	}

	return user, nil
}

// Delete removes a user by ID, returns error if user does not exist
func (r *UserRepository) Delete(id int) error {
	query := `DELETE FROM users WHERE id = $1`
	res, err := r.db.Exec(query, id)
	if err != nil {
		return err
	}

	count, err := res.RowsAffected()
	if err != nil {
		return err
	}

	if count == 0 {
		return sql.ErrNoRows
	}

	return nil
}

// Count returns the total number of users in the database
func (r *UserRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM users`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}
