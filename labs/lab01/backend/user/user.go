package user

import (
	"errors"
	"regexp"
	"strconv"
)

var (
	// ErrInvalidEmail is returned when the email format is invalid
	ErrInvalidEmail = errors.New("invalid email format")
	// ErrInvalidAge is returned when the age is invalid
	ErrInvalidAge = errors.New("invalid age: must be between 0 and 150")
	// ErrInvalidName is returned when the name is empty
	ErrInvalidName = errors.New("name cannot be empty")
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {

	user := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}

	err := user.Validate()

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

	if u.Name == "" {
		return ErrInvalidName
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	// TODO: Implement string representation
	return "Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	if emailRegex.MatchString(email) {
		return true
	}
	return false
}
