package models

import (
	"database/sql"
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

// Validate validates the User
func (u *User) Validate() error {
	if len(u.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}
	
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
		return fmt.Errorf("invalid email format")
	}
	
	return nil
}

// Validate validates the CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}
	
	if req.Email == "" {
		return fmt.Errorf("email is required")
	}
	
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
		return fmt.Errorf("row cannot be nil")
	}
	
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple database rows into User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, fmt.Errorf("rows cannot be nil")
	}
	defer rows.Close()
	
	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan user: %w", err)
		}
		users = append(users, user)
	}
	
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}
	
	return users, nil
}
