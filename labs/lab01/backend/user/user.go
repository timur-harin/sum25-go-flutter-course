package user

import (
	"errors"
	"fmt"
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
	if name == "" {
		return nil, ErrEmptyName
	}
	if age < 0 || age > 150 {
		return nil, ErrInvalidAge
	}
	if !IsValidEmail(email) {
		return nil, ErrInvalidEmail
	}
	return &User{Name: name, Age: age, Email: email}, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.Name == "" {
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
	return "User{Name: \"" + u.Name + "\", Age: " + fmt.Sprintf("%d", u.Age) + ", Email: \"" + u.Email + "\"}"
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	at := -1
	for i, c := range email {
		if c == '@' {
			if at != -1 {
				return false
			}
			at = i
		}
	}
	if at <= 0 || at >= len(email)-3 {
		return false
	}
	dot := false
	for i := at + 1; i < len(email); i++ {
		if email[i] == '.' {
			dot = true
			break
		}
	}
	return dot
}
