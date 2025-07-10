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

// TODO: Implement Create method
func (r *UserRepository) Create(req *models.CreateUserRequest) (*models.User, error) {
	// TODO: Create a new user in the database
	// - Validate the request
	// - Insert into users table
	// - Return the created user with ID and timestamps
	// Use RETURNING clause to get the generated ID and timestamps
	err := req.Validate()
	if err != nil {
		return nil, err
	}
	user := &models.User{}
	err = r.db.QueryRow(`INSERT INTO users(name, email) VALUES ($1, $2) RETURNING id, name, email, created_at, updated_at`, req.Name, req.Email).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
	return nil, fmt.Errorf("TODO: implement Create method")
}

// TODO: Implement GetByID method
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// TODO: Get user by ID from database
	// - Query users table by ID
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `
	  SELECT id, name, email, created_at, updated_at
	  FROM users
	  WHERE id = $1
	`
	user := &models.User{}
	err := r.db.QueryRow(query, id).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
	return nil, fmt.Errorf("TODO: implement GetByID method")
}

// TODO: Implement GetByEmail method
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	// TODO: Get user by email from database
	// - Query users table by email
	// - Return user or sql.ErrNoRows if not found
	// - Handle scanning properly
	query := `
SELECT id, name, email, created_at, updated_at
FROM users
WHERE email = $1
`
	user := &models.User{}
	err := r.db.QueryRow(query, email).
		Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return user, nil
	return nil, fmt.Errorf("TODO: implement GetByEmail method")
}

// TODO: Implement GetAll method
func (r *UserRepository) GetAll() ([]models.User, error) {
	// TODO: Get all users from database
	// - Query all users ordered by created_at
	// - Return slice of users
	// - Handle empty result properly
	users := []models.User{}
	query := `
SELECT id, name, email, created_at, updated_at
FROM users
ORDER BY created_at
`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {

		}
	}(rows)
	for rows.Next() {
		user := models.User{}
		if err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
	return nil, fmt.Errorf("TODO: implement GetAll method")
}

// TODO: Implement Update method
func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	// TODO: Update user in database
	// - Build dynamic UPDATE query based on non-nil fields in req
	// - Update updated_at timestamp
	// - Return updated user
	// - Handle case where user doesn't exist
	var (
		fields []string
		args   []interface{}
		idx    = 1
	)

	if req.Name != nil {
		fields = append(fields, fmt.Sprintf("name = $%d", idx))
		args = append(args, *req.Name)
		idx++
	}
	if req.Email != nil {
		fields = append(fields, fmt.Sprintf("email = $%d", idx))
		args = append(args, *req.Email)
		idx++
	}
	// Нечего обновлять?
	if len(fields) == 0 {
		return nil, fmt.Errorf("nothing to update")
	}

	fields = append(fields, fmt.Sprintf("updated_at = $%d", idx))
	args = append(args, time.Now())
	idx++

	query := fmt.Sprintf(`
        UPDATE users
        SET %s
        WHERE id = $%d
        RETURNING id, name, email, created_at, updated_at
    `, strings.Join(fields, ", "), idx)

	args = append(args, id)

	user := &models.User{}
	err := r.db.QueryRow(query, args...).
		Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("user with id=%d not found", id)
		}
		return nil, err
	}

	return user, nil
}

// TODO: Implement Delete method
func (r *UserRepository) Delete(id int) error {
	// TODO: Delete user from database
	// - Delete from users table by ID
	// - Return error if user doesn't exist
	// - Consider cascading deletes for posts
	res, err := r.db.Exec(`DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
	return fmt.Errorf("TODO: implement Delete method")
}

// TODO: Implement Count method
func (r *UserRepository) Count() (int, error) {
	// TODO: Count total number of users
	// - Return count of users in database
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM users`).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
	return 0, fmt.Errorf("TODO: implement Count method")
}
