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

// Validate checks if the User fields are valid
func (u *User) Validate() error {
	if len(strings.TrimSpace(u.Name)) < 2 {
		return errors.New("name must be at least 2 characters long")
	}
	if !isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// Validate checks if the CreateUserRequest is valid
func (req *CreateUserRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("name must be at least 2 characters long")
	}
	if !isValidEmail(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// ToUser converts CreateUserRequest into a User model
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now().UTC()
	return &User{
		Name:      strings.TrimSpace(req.Name),
		Email:     strings.TrimSpace(req.Email),
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// ScanRow scans a single sql.Row into a User struct
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("nil row")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers reads multiple rows into a slice of Users
func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

// isValidEmail performs basic email format validation
func isValidEmail(email string) bool {
	regex := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	return regex.MatchString(strings.ToLower(email))
}
