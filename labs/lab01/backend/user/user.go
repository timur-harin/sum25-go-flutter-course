package user

import (
	"errors"
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
	u := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}

	if err := u.Validate(); err != nil {
		return nil, err
	}

	return u, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement user validation
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}
	if u.Name == "" {
		return ErrEmptyName
	}
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	// TODO: Implement string representation
	return u.Name + " (" + u.Email + "), age: " + string(rune(u.Age))
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	if len(email) < 5 {
		return false
	}

	atIndex := strings.Index(email, "@")
	if atIndex < 1 || atIndex >= len(email)-1 {
		return false
	}

	domain := email[atIndex+1:]
	dotIndex := strings.LastIndex(domain, ".")
	if dotIndex == -1 || dotIndex == 0 || dotIndex == len(domain)-1 {
		return false
	}

	tld := domain[dotIndex+1:]

	return len(tld) >= 2
}
