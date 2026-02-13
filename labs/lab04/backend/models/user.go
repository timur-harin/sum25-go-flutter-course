package models

import (
	"database/sql"
	"errors"
	"fmt"
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

// Validates an email
func validateEmail(email string) error {
	const usernameCheck int = 0
	const mailServCheck int = 1
	const domainCheck int = 2
	const completed int = 3

	var currentStage int = usernameCheck
	var atSymbolPos int = 0 // Specifies the position of the '@' symbol
	var atSymbolCnt int = 0 // Specifies the number of the '@' symbols met
	for i, ch := range email {
		// Increase the '@' symbol counter
		if ch == '@' {
			atSymbolCnt++
		}

		switch currentStage {
		// Check the username
		case usernameCheck:
			if ch == '@' {
				atSymbolPos = i

				// Check if the username is empty
				if i == 0 {
					return errors.New("empty username")
				}

				// OK -> go to the next stage
				currentStage = mailServCheck
			}

		// Check the mail server
		case mailServCheck:
			if ch == '.' {
				// Check if the mail server is empty
				if atSymbolPos == i-1 { // Previous symbol
					return errors.New("empty mail server")
				}

				// OK -> go to the next stage
				currentStage = domainCheck
			}

		// Check the domain
		case domainCheck:
			// OK -> check is completed
			currentStage = completed

		// Check for miscelleneous errors
		case completed:
			if ch == '.' {
				return errors.New("multiple domains provided")
			}
		}
	}

	// '@' symbol is met more than once
	if atSymbolCnt != 1 {
		return errors.New("'@' symbol is met more than once")
	}

	// The email has invalid structure
	if currentStage != completed {
		return errors.New("incomplete email")
	}

	return nil // OK, no error
}

// Validates user info
func defaultUserInfoValidate(
	name string,
	email string) error {

	// Default value for a validation
	const minNameLength int = 2

	// Check the name
	if len(name) < minNameLength {
		return fmt.Errorf("invalid name: %s", name)
	}

	// Check the email
	return validateEmail(email)
}

// Validates the User
func (u *User) Validate() error {
	return defaultUserInfoValidate(u.Name, u.Email)
}

// Validates the CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	return defaultUserInfoValidate(req.Name, req.Email)
}

// Transforms the CreateUserRequest to a new User
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// Scans a sql.Row to the User
func (u *User) ScanRow(row *sql.Row) error {
	// Check the row
	if row == nil {
		return errors.New("invalid row: nil")
	}

	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt)
}

// Scans a sql.Rows to a User slice
func ScanUsers(rows *sql.Rows) ([]User, error) {
	// Check the rows
	if rows == nil {
		return nil, errors.New("invalid rows: nil")
	}

	defer rows.Close()

	// Scan the rows
	var res []User
	for rows.Next() {
		var user User

		// Scan to the user
		rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt)

		// Add to the result slice
		res = append(res, user)
	}

	return res, rows.Err()
}
