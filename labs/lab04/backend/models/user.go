package models

import (
	"database/sql"
	"fmt"
	"regexp"
	"time"
)

// User represents a user in the system
// This model demonstrates manual SQL operations with database/sql package
// It includes validation, GORM hooks, and manual row scanning capabilities
type User struct {
	ID        int       `json:"id" db:"id"`                 // Primary key, auto-increment
	Name      string    `json:"name" db:"name"`             // User's display name
	Email     string    `json:"email" db:"email"`           // Unique email address
	CreatedAt time.Time `json:"created_at" db:"created_at"` // Record creation timestamp
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"` // Last update timestamp
}

// CreateUserRequest represents the payload for creating a user
// This struct is used for API input validation and transformation
type CreateUserRequest struct {
	Name  string `json:"name"`  // User's display name
	Email string `json:"email"` // User's email address
}

// UpdateUserRequest represents the payload for updating a user
// Uses pointers to distinguish between "not provided" and "empty value"
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`  // Optional name update
	Email *string `json:"email,omitempty"` // Optional email update
}

// Validate performs data validation for User model
// Ensures data integrity before database operations
func (u *User) Validate() error {
	// Name validation: must be at least 2 characters
	if len(u.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}

	// Email validation: must not be empty
	if u.Email == "" {
		return fmt.Errorf("email must not be empty")
	}

	// Email format validation using regex
	emailRe := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRe.MatchString(u.Email) {
		return fmt.Errorf("email is not valid")
	}
	return nil
}

// Validate performs data validation for CreateUserRequest
// Validates input data before creating a new user
func (req *CreateUserRequest) Validate() error {
	// Name validation: must be at least 2 characters
	if len(req.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}

	// Email validation: must not be empty
	if req.Email == "" {
		return fmt.Errorf("email must not be empty")
	}

	// Email format validation using regex
	emailRe := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRe.MatchString(req.Email) {
		return fmt.Errorf("email is not valid")
	}
	return nil
}

// ToUser converts CreateUserRequest to User model
// Sets default timestamps and prepares for database insertion
func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// ScanRow manually scans a database row into User struct
// This method is used with database/sql package for manual SQL operations
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

// ScanUsers scans multiple database rows into a slice of User structs
// This function is used for batch operations with database/sql package
func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User

	for rows.Next() {
		var u User
		err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}
