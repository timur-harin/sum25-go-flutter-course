package repository

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"
)

const userTable = "users"

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
	// TODO: Create a new user in the database
	// - Validate the request
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps

	if err := req.Validate(); err != nil {
		return nil, err
	}

	u := &models.User{
		Name:  req.Name,
		Email: req.Email,
	}
	query := fmt.Sprintf(`
        INSERT INTO %s (name, email, created_at, updated_at)
        VALUES (?, ?, datetime('now'), datetime('now'))
        RETURNING id, created_at, updated_at
    `, userTable)

	err := r.db.QueryRow(query, u.Name, u.Email).
		Scan(&u.ID, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return u, nil
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	u := &models.User{}
	query := fmt.Sprintf(`
        SELECT id, name, email, created_at, updated_at
        FROM %s WHERE id = ?
    `, userTable)

	err := r.db.QueryRow(query, id).
		Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)

	if err != nil {
		return nil, err
	}
	return u, nil
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// TODO: Get user by email from database
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	u := &models.User{}
	query := fmt.Sprintf(`
	SELECT id, name, email, created_at, updated_at
	FROM %s WHERE email = ?
	`, userTable)

	err := r.db.QueryRow(query, email).
		Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)

	if err != nil {
		return nil, err
	}

	return u, nil
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// TODO: Get all users from database
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly

	query := fmt.Sprintf(`
	SELECT id, name, email, created_at, updated_at
	FROM %s ORDER BY created_at`, userTable)

	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}

	defer rows.Close()
	users := []models.User{}

	for rows.Next() {
		var u models.User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	now := time.Now()

	sets := []string{"updated_at = ?"}
	args := []interface{}{now}

	if req.Name != nil {
		sets = append(sets, "name = ?")
		args = append(args, *req.Name)
	}
	if req.Email != nil {
		sets = append(sets, "email = ?")
		args = append(args, *req.Email)
	}
	if len(args) == 1 {
		return r.GetByID(id)
	}

	args = append(args, id)

	query := fmt.Sprintf(`
        UPDATE %s
           SET %s
         WHERE id = ?
      RETURNING id, name, email, created_at, updated_at
    `, userTable, strings.Join(sets, ", "))

	var u models.User
	if err := r.db.QueryRow(query, args...).Scan(
		&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt,
	); err != nil {
		return nil, err
	}
	return &u, nil
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	res, err := r.db.Exec(
		fmt.Sprintf("DELETE FROM %s WHERE id = ?", userTable),
		id,
	)
	if err != nil {
		return err
	}
	n, _ := res.RowsAffected()
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Count
func (r *UserRepository) Count() (int, error) {
	var cnt int
	err := r.db.QueryRow(
		fmt.Sprintf("SELECT COUNT(*) FROM %s", userTable),
	).Scan(&cnt)
	return cnt, err
}
