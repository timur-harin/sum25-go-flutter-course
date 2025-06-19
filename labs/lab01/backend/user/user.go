package user

import (
	"errors"
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
	user := &User{
		Name: name,
		Age: age,
		Email: email,
	}

	if err := user.Validate(); err != nil {
		return nil, err
	}
	return user, nil
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
	return "Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	// Very simple email validation: must contain '@' and '.'
	at := false
	dot := false
	for i, c := range email {
		if c == '@' && i > 0 && i < len(email)-1 {
			at = true
		}
		if c == '.' && i > 0 && i < len(email)-1 {
			dot = true
		}
	}
	return at && dot
}
