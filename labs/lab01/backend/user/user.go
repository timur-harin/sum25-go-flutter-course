package user

import (
	"errors"
	"fmt"
	"regexp"
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

// Validate user's name
func validateName(name string) error {
	if name == "" {
		return ErrEmptyName
	}
	return nil
}

// Validate user's email
func validateEmail(email string) error {
	isMatch, err := regexp.MatchString(`^[A-Za-z0-9._%+-]+@[A-Za-z0-9]+\.[A-Za-z]+$`, email)
	if err != nil {
		return err
	}
	if !isMatch {
		return ErrInvalidEmail
	}
	return nil
}

// Validate user's age
func validateAge(age int) error {
	if age < 0 || age > 150 {
		return ErrInvalidAge
	}
	return nil
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	var user *User = new(User)
	user.Age = age
	user.Email = email
	user.Name = name

	err := user.Validate()
	if err != nil {
		return nil, err
	}
	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if err := validateName(u.Name); err != nil {
		return err
	}
	if err := validateAge(u.Age); err != nil {
		return err
	}
	if err := validateEmail(u.Email); err != nil {
		return err
	}
	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	var userString string = fmt.Sprintf("Name: %s Age: %d Email: %s", u.Name, u.Age, u.Email)
	return userString
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	err := validateEmail(email)
	return (err == nil)
}
