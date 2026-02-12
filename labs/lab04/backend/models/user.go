package models

import (
	"database/sql"
	"time"
	"errors"
	"regexp"
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
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format
	// Return appropriate errors if validation fails
	if !IsValidName(u.Name) {
		return ErrInvalidName
	}
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}
	return nil
}

// TODO: Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format and not empty
	// Return appropriate errors if validation fails
	if !IsValidName(req.Name) {
		return ErrInvalidName
	}
	if !IsValidEmail(req.Email) {
		return ErrInvalidEmail
	}
	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// TODO: Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into User struct
	// Handle the case where row might be nil
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	// TODO: Scan multiple database rows into User slice
	// Make sure to close rows and handle errors properly
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

func IsValidName(name string) bool {
	nameRegex := regexp.MustCompile(`^[a-zA-Zа-яА-ЯёЁ\s]{2,}$`)
	return nameRegex.MatchString(name) && len(name) > 1
}

func IsValidEmail(email string) bool {
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

var (
	ErrInvalidName  = errors.New("invalid name format")
	ErrInvalidEmail = errors.New("invalid email format")
)
