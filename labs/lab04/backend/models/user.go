package models

import (
	"database/sql"
	"errors"
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

// Validate validates the User struct
func (u *User) Validate() error {
	// Name should not be empty and should be at least 2 characters
	if len(u.Name) < 2 {
		return errors.New("name should not be empty and should be at least 2 characters")
	}
	// Email should be valid format
	if !isValidEmail(u.Email) {
		return errors.New("email is not a valid format")
	}
	return nil
}

// Validate validates the CreateUserRequest struct
func (req *CreateUserRequest) Validate() error {
	// Name should not be empty and should be at least 2 characters
	if len(req.Name) < 2 {
		return errors.New("name should not be empty and should be at least 2 characters")
	}
	// Email should not be empty and should be valid format
	if req.Email == "" {
		return errors.New("email should not be empty")
	}
	if !isValidEmail(req.Email) {
		return errors.New("email is not a valid format")
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

// ScanRow scans a single sql.Row into User
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		// Return error if row is nil
		return errors.New("row is nil")
	}
	// Scan row into User struct
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple sql.Rows into a slice of User
func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close() // Always close rows after use
	var users []User
	for rows.Next() {
		var u User
		// Scan each row into a User struct
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	// Check for errors after iteration
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}

// isValidEmail checks if the email has a valid format
func isValidEmail(email string) bool {
	// Simple regex for email validation
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}
