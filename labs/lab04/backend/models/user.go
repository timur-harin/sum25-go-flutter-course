package models

import (
	"database/sql"
	"errors"
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

// Validate method for User
func (u *User) Validate() error {
	if len(strings.TrimSpace(u.Name)) < 2 {
		return errors.New("имя должно содержать минимум 2 символа")
	}

	if !isValidEmail(u.Email) {
		return errors.New("неверный формат email")
	}

	return nil
}

// Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("имя должно содержать минимум 2 символа")
	}

	if req.Email == "" {
		return errors.New("email не может быть пустым")
	}

	if !isValidEmail(req.Email) {
		return errors.New("неверный формат email")
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
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, errors.New("rows is nil")
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

// Helper function to validate email format
func isValidEmail(email string) bool {
	// Simple email validation regex
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}
