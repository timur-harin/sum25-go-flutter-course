package models

import (
	"database/sql"
	"errors"
	"regexp"
	"time"
)

// User represents a user in the system
type User struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest represents the payload for creating a user
type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

// UpdateUserRequest represents the payload for updating a user
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

// Implement Validate method for User
func (u *User) Validate() error {
	// Add validation logic
	// - Name should not be empty and should be at least 2 characters
	if len(u.Name) < 2 {
		return errors.New("name should be at least 2 characters")
	}
	// - Email should be valid format
	if !regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`).MatchString(u.Email) {
		return errors.New("email should be valid format")
	}
	// Return appropriate errors if validation fails
	return nil
}

// Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// Add validation logic
	// - Name should not be empty and should be at least 2 characters
	if len(req.Name) < 2 {
		return errors.New("name should be at least 2 characters")
	}
	// - Email should be valid format
	if !regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`).MatchString(req.Email) {
		return errors.New("email should be valid format")
	}
	// Return appropriate errors if validation fails
	return nil
}

// Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	// Convert CreateUserRequest to User
	// Set timestamps to current time
	return &User{Name: req.Name, Email: req.Email, CreatedAt: time.Now(), UpdatedAt: time.Now()}
}

// Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	// Scan database row into User struct
	// Handle the case where row might be nil
	if row == nil {
		return errors.New("sql row is nil")
	}
	err := row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
	if err != nil {
		return err
	}
	return nil
}

// Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	// Scan multiple database rows into User slice
	// Make sure to close rows and handle errors properly
	defer rows.Close()
	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}
