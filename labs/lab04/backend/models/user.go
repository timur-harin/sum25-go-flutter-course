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

// Validate checks if the user data is valid.
// Name must be at least 2 characters and email must be in valid format.
// Returns ErrInvalidName or ErrInvalidEmail if validation fails.
func (u *User) Validate() error {
	if len(u.Name) < 2 {
		return ErrInvalidName
	}

	_, err := mail.ParseAddress(u.Email)
	if err != nil {
		return ErrInvalidEmail
	}

	return nil
}

// Validate checks if the create user request data is valid.
// Name must be at least 2 characters and email must be in valid format.
// Returns ErrInvalidName or ErrInvalidEmail if validation fails.
func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return ErrInvalidName
	}

	_, err := mail.ParseAddress(req.Email)
	if err != nil {
		return ErrInvalidEmail
	}

	return nil
}

// ToUser converts CreateUserRequest to a User model with current timestamp
// for CreatedAt and UpdatedAt fields.
func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// ScanRow scans a database row into User struct fields.
// Returns error if scanning fails.
func (u *User) ScanRow(row *sql.Row) error {
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

// ScanUsers scans multiple database rows into a slice of Users.
// Returns the users slice and error if scanning fails.
// Returns sql.ErrNoRows if rows is nil.
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
