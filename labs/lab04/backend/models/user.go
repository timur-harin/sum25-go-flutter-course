package models

import (
	"database/sql"
	"errors"
	"regexp"
	"time"
)

var (
	ErrInvalidName  = errors.New("Invalid name")
	ErrInvalidEmail = errors.New("Invalid email")
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

	if u.Name == "" || len(u.Name) < 2 {
		return ErrInvalidName
	}
	pattern := "^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*)@" +
		"(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\\.)+" +
		"[A-Za-z]{2,}$"

	re := regexp.MustCompile(pattern)

	if !re.MatchString(u.Email) {
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

	if req.Name == "" || len(req.Name) < 2 {
		return ErrInvalidName
	}
	pattern := "^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*)@" +
		"(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\\.)+" +
		"[A-Za-z]{2,}$"

	re := regexp.MustCompile(pattern)

	if !re.MatchString(req.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	// TODO: Convert CreateUserRequest to User
	// Set timestamps to current time
	now := time.Now()

	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// TODO: Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into User struct
	// Handle the case where row might be nil
	if row == nil {
		return sql.ErrNoRows
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

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, sql.ErrNoRows
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		); err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
