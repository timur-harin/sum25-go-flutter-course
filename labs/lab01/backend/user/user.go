package user

import (
	"errors"
	"strings"
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
	if !IsValidEmail(email) {
		return nil, ErrInvalidEmail
	}
	if age < 0 || age > 150 {
		return nil, ErrInvalidAge
	}
	if name == "" {
		return nil, ErrEmptyName
	}
	user := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}
	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}
	if u.Name == "" {
		return ErrEmptyName
	}
	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return "User{Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email + "}"
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	at := strings.Index(email, "@")
	dot := strings.LastIndex(email, ".")
	return at > 0 && dot > at+1 && dot < len(email)-1
}
