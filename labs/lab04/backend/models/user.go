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

// TODO: Implement Validate method for User
func (u *User) Validate() error {
	// Name validation
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if len(strings.TrimSpace(u.Name)) < 2 {
		return errors.New("name must be at least 2 characters long")
	}

	// Email validation
	if strings.TrimSpace(u.Email) == "" {
		return errors.New("email cannot be empty")
	}

	// Simple email regex validation
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
		return errors.New("invalid email format")
	}

	return nil
}

// TODO: Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// Name validation
	if strings.TrimSpace(req.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("name must be at least 2 characters long")
	}

	// Email validation
	if strings.TrimSpace(req.Email) == "" {
		return errors.New("email cannot be empty")
	}

	// Simple email regex validation
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(req.Email) {
		return errors.New("invalid email format")
	}

	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
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
	if row == nil {
		return errors.New("row cannot be nil")
	}

	err := row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return fmt.Errorf("failed to scan user row: %w", err)
	}

	return nil
}

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, errors.New("rows cannot be nil")
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user row: %w", err)
		}
		users = append(users, user)
	}

	// Check for errors from iterating over rows
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating over rows: %w", err)
	}

	return users, nil
}
