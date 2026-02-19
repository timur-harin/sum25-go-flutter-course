package models

import (
	"database/sql"
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

// Validate validates User fields
func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}

	if len(strings.TrimSpace(u.Name)) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}

	if strings.TrimSpace(u.Email) == "" {
		return fmt.Errorf("email cannot be empty")
	}

	// Simple email validation
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
		return fmt.Errorf("invalid email format")
	}

	return nil
}

// Validate validates CreateUserRequest fields
func (req *CreateUserRequest) Validate() error {
	if strings.TrimSpace(req.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}

	if len(strings.TrimSpace(req.Name)) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}

	if strings.TrimSpace(req.Email) == "" {
		return fmt.Errorf("email cannot be empty")
	}

	// Simple email validation
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(req.Email) {
		return fmt.Errorf("invalid email format")
	}

	return nil
}

// ToUser converts CreateUserRequest to User
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// ScanRow scans database row into User struct
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}

	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple database rows into User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, fmt.Errorf("rows is nil")
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user row: %v", err)
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %v", err)
	}

	return users, nil
}
