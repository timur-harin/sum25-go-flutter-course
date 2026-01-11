package models

import (
	"database/sql"
	"errors"
	"strings"
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

// Validate method for User
func (u *User) Validate() error {
	if utf8.RuneCountInString(u.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if u.Email == "" {
		return errors.New("email is required")
	}
	if !isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	if req.Name == "" {
		return errors.New("name is required")
	}
	if utf8.RuneCountInString(req.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if req.Email == "" {
		return errors.New("email is required")
	}
	if !isValidEmail(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	var users []User
	defer rows.Close()

	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
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

// Helper function for email validation
func isValidEmail(email string) bool {
	// Simple email validation - in production use a proper regex or library
	return len(email) >= 3 && len(email) <= 254 &&
		strings.Contains(email, "@") &&
		strings.Contains(email, ".")
}
