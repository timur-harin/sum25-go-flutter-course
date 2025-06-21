package user

import (
	"errors"
	"strings"
	"fmt"
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
	if name==""{
		return nil, ErrEmptyName
	}
	if age<18 || age>100{
		return nil, ErrInvalidAge
	}
	if !strings.Contains(email,"@"){
		return nil, ErrInvalidEmail
	}
	user:= &User{
		Name: name,
		Age: age, 
		Email: email,
	}
	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.Name==""{
		return ErrEmptyName
	}
	if u.Age<18 || u.Age>100{
		return ErrInvalidAge
	}
	if !strings.Contains(u.Email,"@"){
		return ErrInvalidEmail
	}
	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
	return fmt.Sprintf("%s %d %s", u.Name, u.Age, u.Email)
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
	return strings.Contains(email,"@")
}
