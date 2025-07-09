package models

import (
	"database/sql"
	"errors"
	"fmt"
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

// Regexp for email validation
var emailRegexp = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func (u *User) Validate() error {
	if len(u.Name) < 2 {
		return ErrInvalidName
	}
	if !emailRegexp.MatchString(u.Email) {
		return ErrInvalidEmail
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return ErrInvalidName
	}
	if !emailRegexp.MatchString(req.Email) {
		return ErrInvalidEmail
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	timeNow := time.Now()

	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: timeNow,
		UpdatedAt: timeNow,
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}

	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()

	users := make([]User, 0, 5)
	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan the row: %v", err)
		}
		users = append(users, u)
	}

	return users, nil
}

var (
	ErrInvalidName  = errors.New("name must be at least 2 characters long")
	ErrInvalidEmail = errors.New("invalid email format")
)
