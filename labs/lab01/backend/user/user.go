package user

import (
	"errors"
	"fmt"
	"strings"
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
	newUser := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}

	if err := newUser.Validate(); err != nil {
		return nil, err
	}

	return newUser, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidName(u.Name) {
		return ErrInvalidName
	}

	if !IsValidAge(u.Age) {
		return ErrInvalidAge
	}

	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	if email == "" {
		return false
	}

	at := strings.Index(email, "@")
	if at <= 0 {
		return false
	}

	dot := strings.LastIndex(email, ".")
	if dot <= at+1 {
		return false
	}

	if dot >= len(email)-1 {
		return false
	}

	return true
}

// IsValidName checks if the name is valid
func IsValidName(name string) bool {
	return len(name) > 0 && len(name) <= 30
}

// IsValidAge checks if the age is valid
func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
