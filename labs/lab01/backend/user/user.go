package user

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
)

// Predefined errors
var (
	ErrEmptyName    = errors.New("name cannot be empty")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return ErrEmptyName
	}

	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	user := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}

	if err := user.Validate(); err != nil {
		return nil, err
	}

	return user, nil
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	return false
}
