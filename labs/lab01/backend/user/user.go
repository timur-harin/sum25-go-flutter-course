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
		Name:  name,
		Age:   age,
		Email: email,
	}

	return user, user.Validate()
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
	str := u.Name + " " + strconv.Itoa(u.Age) + " " + u.Email
	return str
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	emailRegex := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`)
	return emailRegex.MatchString(email)
}
