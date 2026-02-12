package user

import (
	"errors"
	"fmt"
	"regexp"
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

	if !(age >= 0 && age <= 150) {
		return nil, ErrInvalidAge
	}

	re, _ := regexp.Compile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

	if !re.Match([]byte(email)) {
		return nil, ErrInvalidEmail
	}

	if len(name) == 0 {
		return nil, ErrInvalidName
	}

	return &User{
		Name:  name,
		Age:   age,
		Email: email,
	}, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {

	if !(u.Age >= 0 && u.Age <= 150) {
		return ErrInvalidAge
	}

	re, _ := regexp.Compile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

	if !re.Match([]byte(u.Email)) {
		return ErrInvalidEmail
	}

	if len(u.Name) == 0 {
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
	re, _ := regexp.Compile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

	return re.Match([]byte(email))
}
