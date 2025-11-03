package user

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
)

// Predefined errors
var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

type User struct {
	Name  string
	Age   int
	Email string
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
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
	if len(strings.TrimSpace(u.Name)) == 0 || len(u.Name) > 30 {
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

// IsValidEmail checks if the email format is valid using regex
func IsValidEmail(email string) bool {
	// Simple regex for email validation
	const emailRegex = `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(emailRegex)
	return re.MatchString(email)
}

// IsValidAge checks if the age is between 0 and 150 inclusive
func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
