package user

import (
	"errors"
	"net/mail"
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

	if strings.TrimSpace(name) == "" {
		return nil, ErrEmptyName
	}

	if age > 150 || age < 0 {
		return nil, ErrInvalidAge
	}

	if _, err := mail.ParseAddress(email); err != nil {
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
	// TODO: Implement user validation
	if strings.TrimSpace(u.Name) == "" {
		return ErrEmptyName
	}

	if u.Age > 150 || u.Age < 0 {
		return ErrInvalidAge
	}

	if _, err := mail.ParseAddress(u.Email); err != nil {
		return ErrInvalidEmail
	}
	return nil
}

// String returns a string representation of the user
func (u *User) String() string {

	return "User{Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email + "}"
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	_, err := mail.ParseAddress(email)
	return err == nil
}
