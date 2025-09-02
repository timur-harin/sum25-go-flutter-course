package user

import (
	"errors"
	"strings"
	"fmt"
)

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
	user := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}

	err := user.Validate();

	if err != nil {
		return nil, err
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
	if strings.TrimSpace(u.Name) == "" {
		return ErrInvalidName
	}
	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	at := strings.Index(email, "@")
	dot := strings.LastIndex(email, ".")
	return at > 0 && dot > at+1 && dot < len(email)-1
}