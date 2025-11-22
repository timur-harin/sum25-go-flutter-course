package models

import (
	"database/sql"
	"errors"
	"regexp"
	"time"
)

var (
	ErrInvalidName  = errors.New("invalid name")
	ErrInvalidEmail = errors.New("invalid email")
	ErrNilRow       = errors.New("nil row")
)

var (
	emailRE = regexp.MustCompile(`^\S+@\S+\.\S+$`)
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

func validateName(name string) error {
	if len(name) < 2 {
		return ErrInvalidName
	}
	return nil
}

func validateEmail(email string) error {
	if !emailRE.MatchString(email) {
		return ErrInvalidEmail
	}
	return nil
}

func (u *User) Validate() error {
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format

	if err := validateName(u.Name); err != nil {
		return err
	}
	if err := validateEmail(u.Email); err != nil {
		return err
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format and not empty

	if err := validateName(req.Name); err != nil {
		return err
	}
	if err := validateEmail(req.Email); err != nil {
		return err
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	// Set timestamps to current time

	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	// Handle the case where row might be nil

	if row == nil {
		return ErrNilRow
	}

	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	// Make sure to close rows and handle errors properly

	if rows == nil {
		return []User{}, ErrNilRow
	}
	users := make([]User, 0)

	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	return users, nil
}
