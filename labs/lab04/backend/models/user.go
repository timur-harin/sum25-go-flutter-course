package models

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"strings"
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

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name is required")
	}
	if len(u.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if strings.TrimSpace(u.Email) == "" {
		return errors.New("email is required")
	}
	if !emailRegex.MatchString(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if strings.TrimSpace(req.Name) == "" {
		return errors.New("name is required")
	}
	if len(req.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if strings.TrimSpace(req.Email) == "" {
		return errors.New("email is required")
	}
	if !emailRegex.MatchString(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	users := []User{}

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
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %w", err)
	}

	return users, nil
}
