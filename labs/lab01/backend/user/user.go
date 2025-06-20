package user

import (
	"errors"
	"net/mail"
	"strconv"
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
	if _, err := mail.ParseAddress(email); err != nil {
		return nil, ErrInvalidEmail
	} else if age < 0 || age > 150 {
		return nil, ErrInvalidAge
	} else if name == "" {
		return nil, ErrEmptyName
	} else {
		return &User{name, age, email}, nil
	}
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement user validation
	if _, err := mail.ParseAddress(u.Email); err != nil {
		return ErrInvalidEmail
	} else if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	} else if u.Name == "" {
		return ErrEmptyName
	} else {
		return nil
	}
}

// String returns a string representation of the user
func (u *User) String() string {
	// TODO: Implement string representation
	return u.Name + " " + u.Email + strconv.Itoa(u.Age)
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	if _, err := mail.ParseAddress(email); err != nil {
		return false
	}
	return true
}
