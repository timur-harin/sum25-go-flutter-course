package user

import (
	"errors"
	"fmt"
	"strconv"
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

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement user validation
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

// String returns a string representation of the user, formatted as "Name: <name>, Age: <age>, Email: <email>"
func (u *User) String() string {
	// TODO: Implement string representation
	age := strconv.Itoa(u.Age)
	s := fmt.Sprintf("Name: %s, Age: %s, Email: %s", u.Name, age, u.Email)
	return s
}

// NewUser creates a new user with validation, returns an error if the user is not valid
func NewUser(name string, age int, email string) (*User, error) {
	// TODO: Implement this function
	var user User = User{Name: name, Age: age, Email: email}
	if !IsValidEmail(email) {
		return &user, ErrInvalidEmail
	} else if age < 0 || age > 150 {
		return &user, ErrInvalidAge
	} else if name == "" {
		return &user, ErrInvalidName
	}
	return &user, nil
}

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	// TODO: Implement email validation
	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return false
	}
	if len(parts[0]) == 0 || len(parts[1]) == 0 {
		return false
	}

	if !strings.Contains(parts[1], ".") || strings.HasPrefix(parts[1], ".") || strings.HasSuffix(parts[1], ".") {
		return false
	}

	return true
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	// TODO: Implement this function
	if len(name) >= 1 && len(name) <= 30 {
		return true
	}
	return false
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	// TODO: Implement this function
	if age >= 0 && age <= 150 {
		return true
	}
	return false
}
