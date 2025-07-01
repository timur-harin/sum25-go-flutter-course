package user

import (
	"errors"
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

// Validate checks if the user data is valid, returns an error for each invalid field
func (u *User) Validate() error {
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
	return "Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email
}

// NewUser creates a new user with validation, returns an error if the user is not valid
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

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	if len(email) < 5 {
		return false
	}

	atIndex := strings.Index(email, "@")
	if atIndex < 1 || atIndex >= len(email)-1 {
		return false
	}

	domain := email[atIndex+1:]
	dotIndex := strings.LastIndex(domain, ".")
	if dotIndex == -1 || dotIndex == 0 || dotIndex == len(domain)-1 {
		return false
	}

	tld := domain[dotIndex+1:]

	return len(tld) >= 2
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	if (len(name) > 30 || name == "") {return false}
	return true
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	if age <= 0 || age > 150 {
		return false
	}
	return true
}