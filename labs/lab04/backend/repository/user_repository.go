package repository

import (
	"database/sql"
	"errors"
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

// Create creates a user according to the provided CreateUserRequest
// in the UserRepository and returns the User structure
func (r *UserRepository) Create(
	req *models.CreateUserRequest) (*models.User, error) {
	// Validate the request
	validErr := req.Validate()
	if validErr != nil {
		return nil, validErr
	}

	// Insert name and email
	// Get the serial ID, created & updated at timestamp values
	query := `INSERT INTO users (name, email)
			  VALUES ($1, $2)
			  RETURNING id, name, email, created_at, updated_at
			  `

	// Get the row
	user := req.ToUser()
	row := r.db.QueryRow(query, user.Name, user.Email)

	return user, user.ScanRow(row)
}

// GetByID gets a user from the UserRepository by ID
func (r *UserRepository) GetByID(id int) (*models.User, error) {
	// Similar to the GetByEmail()
	query := `SELECT id, name, email, created_at, updated_at
			  FROM users WHERE id = $1`

	// Get the related row
	row := r.db.QueryRow(query, id)
	if row == nil { // No record
		return nil, sql.ErrNoRows
	}

	// Exctract user info
	var user models.User
	return &user, user.ScanRow(row)
}

// GetByEmail gets a user from the UserRepository by email
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at
			  FROM users WHERE email = $1`

	// Get the related row
	row := r.db.QueryRow(query, email)
	if row == nil { // No record
		return nil, sql.ErrNoRows
	}

	// Exctract user info
	var user models.User
	return &user, user.ScanRow(row)
}

// GetAll gets all the users from the UserRepository
func (r *UserRepository) GetAll() ([]models.User, error) {
	query := `SELECT id, name, email, created_at, updated_at
			  FROM users ORDER BY created_at
			`

	// Get the rows with user info
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, errors.New("failed to get all users")
	}

	// Scan users from the rows
	return models.ScanUsers(rows)
}

// Update updates the user with the spoecified id in the UserRepository
func (r *UserRepository) Update(id int,
	req *models.UpdateUserRequest) (*models.User, error) {
	// Get the user
	user, err := r.GetByID(id)

	// Check if the user does not exist
	if err != nil {
		return user, err
	}

	var lastArgNo int = 1
	var args []string        // Slice of the arguments to be set
	var vaArgs []interface{} // Arguments to be passed in a SQL Query

	// Set the provided name
	if req.Name != nil {
		nameQuery := fmt.Sprintf("name = $%d", lastArgNo)
		args = append(args, nameQuery)
		vaArgs = append(vaArgs, *req.Name)
		lastArgNo++
	}

	// Set the provided name
	if req.Email != nil {
		emailQuery := fmt.Sprintf("email = $%d", lastArgNo)
		args = append(args, emailQuery)
		vaArgs = append(vaArgs, *req.Email)
		lastArgNo++
	}

	// Update the time
	now := time.Now()
	timeQuery := fmt.Sprintf("updated_at = $%d", lastArgNo)
	args = append(args, timeQuery)
	vaArgs = append(vaArgs, now)
	lastArgNo++

	query := fmt.Sprintf(`UPDATE users
			  SET
			  	%s
			  WHERE id = $%d
			  RETURNING id, name, email, created_at, updated_at
			 `, strings.Join(args, ","), lastArgNo)
	vaArgs = append(vaArgs, id)
	lastArgNo++

	print("\n\n\n" + query)

	// Update the related row
	res, execErr := r.db.Exec(query, vaArgs...)
	if execErr != nil {
		print("\n\nERROR: ", execErr.Error())
		return nil, errors.New("failed to update user info")
	}

	// User was not found
	if affected, _ := res.RowsAffected(); affected == 0 {
		return nil, sql.ErrNoRows
	}

	// Update the user
	return r.GetByID(id)
}

// Delete deletes a user from the UserRepository
func (r *UserRepository) Delete(id int) error {
	// Execute the query
	query := `DELETE FROM users WHERE id = $1`
	res, execErr := r.db.Exec(query, id)

	// Execution failed
	if execErr != nil {
		return fmt.Errorf("failed to delete a user with ID %d", id)
	}

	// Check if the user was deleted
	if affected, err := res.RowsAffected(); err != nil || affected == 0 {
		return fmt.Errorf("user with ID %d does not exist", id)
	}

	return nil // OK, no error
}

// Count returns the count of all users in the UserRepository
func (r *UserRepository) Count() (int, error) {
	var cnt int = 0

	// Perform the query and write the result to "cnt"
	query := `SELECT COUNT(*) FROM users`
	err := r.db.QueryRow(query).Scan(&cnt)

	// Return the result
	return cnt, err
}
