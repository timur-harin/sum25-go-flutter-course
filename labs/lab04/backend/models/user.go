package models

import (
	"database/sql"
	"errors"
	"regexp"
	"time"
)

// private functions to validate email and name formats

// Function to check if an email is valid
func _isValidEmail(email string) bool {
	if len(email) == 0 {
		return false
	}
	// Simple regex for email validation (not comprehensive)
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}

// Function to check if a name is valid
func _isValidName(name string) bool {
	if len(name) < 2 || name == "" {
		return false
	}
	return true
}

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
	if !_isValidName(u.Name) {
		return errors.New("invalid name format")
	}
	if !_isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// Validate method for CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	if !_isValidName(req.Name) {
		return errors.New("invalid name format")
	}

	if !_isValidEmail(req.Email) {
		return errors.New("invalid email format")
	}

	return nil
}

// TODO: Implement ToUser method for CreateUserRequest
func (req *CreateUserRequest) ToUser() *User {
	// TODO: Convert CreateUserRequest to User
	// Set timestamps to current time
	userName := req.Name
	userEmail := req.Email
	user := &User{
		Name:      userName,
		Email:     userEmail,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return user
}

// ScanRow scans a single database row into the User struct
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple database rows into a slice of User structs
func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}
