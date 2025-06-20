package user

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
)

var (
	// ErrInvalidEmail is returned when the email format is invalid
	ErrInvalidEmail = errors.New("invalid email format")
	// ErrInvalidAge is returned when the age is invalid
	ErrInvalidAge = errors.New("invalid age: must be between 0 and 150")
	// ErrEmptyName is returned when the name is empty
	ErrEmptyName = errors.New("name cannot be empty")
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	// TODO: Implement user creation with validation
	var user User = User{Name: name, Age: age, Email: email}
	if !IsValidEmail(email) {
		return &user, ErrInvalidEmail
	} else if age < 0 || age > 150 {
		return &user, ErrInvalidAge
	} else if name == "" {
		return &user, ErrEmptyName
	}
	return &user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement user validation
	if strings.TrimSpace(u.Name) == "" {
		return ErrEmptyName
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
	// TODO: Implement string representation
	age := strconv.Itoa(u.Age)
	s := fmt.Sprintf("%s %s %s", u.Name, age, u.Email)
	return s
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return false
	}
	if len(parts[0]) == 0 || len(parts[1]) == 0 {
		return false
	}

	if !strings.Contains(parts[1], ".") || strings.HasPrefix(parts[1], ".") || strings.HasSuffix(parts[1], ".") {
		return false
	}

	return true
}
