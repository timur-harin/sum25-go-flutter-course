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

// TODO: Implement Validate method for User
func (u *User) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format
	// Return appropriate errors if validation fails
	if u.Name == "" || len(u.Name) < 2 {
		return errors.New("name is too short or empty")
	}
	emailRegexp := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	if !emailRegexp.MatchString(u.Email) || u.Email == "" {
		return errors.New("email is invalid")
	}
	return nil
}

// TODO: Implement Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	// TODO: Add validation logic
	// - Name should not be empty and should be at least 2 characters
	// - Email should be valid format and not empty
	// Return appropriate errors if validation fails
	if req.Name == "" || len(req.Name) < 2 {
		return errors.New("name is too short or empty")
	}
	emailRegexp := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	if !emailRegexp.MatchString(req.Email) || req.Email == "" {
		return errors.New("email is invalid")
	}
	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	// TODO: Convert CreateUserRequest to User
	// Set timestamps to current time
	user := &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return user
}

// TODO: Implement ScanRow method for User
func (u *User) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into User struct
	// Handle the case where row might be nil
	err := row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return err
	}
	return nil
}

// TODO: Implement ScanRows method for User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	// TODO: Scan multiple database rows into User slice
	// Make sure to close rows and handle errors properly
	var users []User
	err := rows.Scan(&users[0].ID, &users[0].Name, &users[0].CreatedAt, &users[0].UpdatedAt)
	if err != nil {
		return nil, err
	}
	return users, nil
}
