package user

import (
	"errors"
	"regexp"
	"strconv"
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
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	// Regular expression for validating an email
	const emailRegex = `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	return regexp.MustCompile(emailRegex).MatchString(email)
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	if len(name) == 0 || len(name) > 30 {
		return false
	}
	// Check if the name contains only letters and spaces
	for _, char := range name {
		if !((char >= 'A' && char <= 'Z') || (char >= 'a' && char <= 'z') || char == ' ') {
			return false
		}
	}
	return true
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
