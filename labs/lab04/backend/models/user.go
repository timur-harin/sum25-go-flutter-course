package models

import (
	"database/sql"
	"errors"
	"fmt"
	"net/mail"
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

var (
	ErrInvalidName  = errors.New("name should not be empty and should be at least 2 characters")
	ErrInvalidEmail = errors.New("invalid email format")
)

// TODO: Implement Validate method for User
func (u *User) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format
	// Return appropriate errors if validation fails

	if len(u.Name) < 2 {
		return ErrInvalidName
	}

	_, err := mail.ParseAddress(u.Email)
	if err != nil {
		return ErrInvalidEmail
	}

	return nil
}

// TODO: Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format and not empty
	// Return appropriate errors if validation fails

	if len(req.Name) < 2 {
		return ErrInvalidName
	}

	_, err := mail.ParseAddress(req.Email)
	if err != nil {
		return ErrInvalidEmail
	}

	return nil
}

// CreateUserRequest converts CreateUserRequest to User
func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// ScanRow scans a row from sql.Row into the User. Returns error if scan failed
func (u *User) ScanRow(row *sql.Row) error {
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

// ScanUsers scans rows into User slice. Returns error if scan failed
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, sql.ErrNoRows
	}
	defer rows.Close()

	users := make([]User, 0, 8)

	for rows.Next() {
		var user User
		if err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("error scanning row: %w", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return users, nil
}
