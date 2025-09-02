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

// Validate validates the User model
func (u *User) Validate() error {
	if len(u.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if !isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// Validate validates the CreateUserRequest
func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if len(req.Email) == 0 {
		return errors.New("email is required")
	}
	if !isValidEmail(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// ToUser converts CreateUserRequest to User with timestamps
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// ScanRow scans a single sql.Row into a User
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple sql.Rows into a slice of User
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

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

// isValidEmail checks for basic email format using regex
func isValidEmail(email string) bool {
	regex := `^[a-zA-Z0-9._%%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(regex)
	return re.MatchString(email)
}
