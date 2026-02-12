package user

import (
	"errors"
	"strings"
	"strconv"
)

// Predefined errors
var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	name = strings.TrimSpace(name)
	if len(name) == 0 || len(name) > 30 {
		return nil, ErrInvalidName
	}

	if age < 0 || age > 150 {
		return nil, ErrInvalidAge
	}

	email = strings.TrimSpace(email)
	if !IsValidEmail(email) {
		return nil, ErrInvalidEmail
	}

	return &User{
		Name:  name,
		Age:   age,
		Email: email,
	}, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if len(strings.TrimSpace(u.Name)) == 0 || len(u.Name) > 30 {
		return ErrInvalidName
	}

	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}

	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return "Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	email = strings.TrimSpace(email)
	if email == "" {
		return false
	}

	// Check for spaces
	if strings.ContainsAny(email, " \t\n\r") {
		return false
	}

	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return false
	}

	if parts[0] == "" || parts[1] == "" {
		return false
	}

	// Check domain part has at least one dot
	if !strings.Contains(parts[1], ".") {
		return false
	}

	return true
}