package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"lab04-backend/models"
	"strings"
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
	if err := req.Validate(); err != nil {
		return nil, err
	}

	result, err := r.db.Exec(`INSERT INTO users (name, email, created_at, updated_at) VALUES ($1, $2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`,
		req.Name, req.Email)
	if err != nil {
		return nil, err
	}
	id, err := result.LastInsertId() // get the id of the previosly inserted user
	if err != nil {
		return nil, err
	}
	return r.GetByID(int(id))
}

func (r *UserRepository) GetByID(id int) (*models.User, error) {
	row := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1`, id) // r.db - database connection

	var user models.User // struct representing a user from my app

	if err := user.ScanRow(row); err != nil { // ScanRow is a custom method on User to scan from a row
		return nil, err
	}

	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	row := r.db.QueryRow(`SELECT id, name, email, created_at, updated_at FROM users WHERE email = $1`, email) // r.db - database connection

	var user models.User // struct representing a user from my app

	if err := user.ScanRow(row); err != nil { // ScanRow is a custom method on User to scan from a row
		return nil, err
	}

	return &user, nil
}

func (r *UserRepository) GetAll() ([]models.User, error) {
	rows, err := r.db.Query(`SELECT id, name, email, created_at, updated_at FROM users WHERE deleted_at IS NULL ORDER BY created_at`) // r.db - database connection
	if err != nil {
		return nil, err
	}
	return models.ScanUsers(rows)
}

func (r *UserRepository) Update(id int, req *models.UpdateUserRequest) (*models.User, error) {
	if req == nil || (req.Email == nil && req.Name == nil) {
		return nil, errors.New("no fields to update")
	}
	var (
		setClauses []string
		args       []interface{}
		argPos     = 1
	)

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
	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argPos))
	args = append(args, time.Now())
	argPos++
	query := fmt.Sprintf(`UPDATE users SET %s WHERE deleted_at IS NULL AND id = $%d RETURNING id, name, email, created_at, updated_at`, strings.Join(setClauses, ","), argPos)
	args = append(args, id)
	row := r.db.QueryRow(query, args[0], args[1], args[2], args[3])
	var user models.User
	if err := user.ScanRow(row); err != nil { // ScanRow is a custom method on User to scan from a row
		if errors.Is(err, sql.ErrNoRows) { // special check for a common database situation when a query does not return any rows
			return nil, fmt.Errorf("user with id %d not found", id)
		}
		return nil, err
	}

	return &user, nil

}

func (r *UserRepository) Delete(id int) error {
	result, err := r.db.Exec(`DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return errors.New("failed to delete the user by id")
	}

	rowsAffected, err := result.RowsAffected()

	if err != nil {
		return errors.New("failed to get rows affected")
	}

	if rowsAffected == 0 {
		return fmt.Errorf("user with id %d was not found", id)
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
