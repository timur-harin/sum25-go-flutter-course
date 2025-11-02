package models

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"time"
	"unicode/utf8"
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

// TODO: Implement Validate method for User
func (u *User) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format
	// Return appropriate errors if validation fails
	if u.Name == "" {
		return ErrEmptyName
	} else if utf8.RuneCountInString(u.Name) < 2 {
		return ErrTooShortName
	}

	if u.Email == "" {
		return ErrEmptyEmail
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
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
	if req.Name == "" {
		return ErrEmptyName
	} else if utf8.RuneCountInString(req.Name) < 2 {
		return ErrTooShortName
	}

	if req.Email == "" {
		return ErrEmptyEmail
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(req.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	// TODO: Convert CreateUserRequest to User
	// Set timestamps to current time
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// TODO: Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into User struct
	// Handle the case where row might be nil
	err := row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrEmptyRow
		}
		return fmt.Errorf("fail while scanning the row: %w ", err)
	}

	return nil
}

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	// TODO: Scan multiple database rows into User slice
	// Make sure to close rows and handle errors properly
	users := make([]User, 0)

	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {
			fmt.Printf("failed while closing rows: %s", err)
		}
	}(rows)

	for rows.Next() {
		var user User
		err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("error while scanning rows: %w", err)
		}

		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error during rows iteration: %w", err)
	}

	return users, nil
}

var (
	ErrEmptyName    = errors.New("name cannot be empty")
	ErrTooShortName = errors.New("name has to be at least 2 characters long")
	ErrEmptyEmail   = errors.New("email is empty")
	ErrInvalidEmail = errors.New("invalid email")
	ErrEmptyRow     = errors.New("row is empty")
)
