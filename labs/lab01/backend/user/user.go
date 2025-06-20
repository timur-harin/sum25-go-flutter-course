package user

import (
	"errors"
	"strings"
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
	name = strings.TrimSpace(name)
	if name == "" {
		return nil, ErrEmptyName
	}

	// Проверяем возраст
	if age < 0 || age > 150 {
		return nil, ErrInvalidAge
	}

	// Проверяем email
	if !IsValidEmail(email) {
		return nil, ErrInvalidEmail
	}

	return &User{
		Name:  name,
		Age:   age,
		Email: strings.TrimSpace(email),
	}, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// Проверяем имя
	if strings.TrimSpace(u.Name) == "" {
		return ErrEmptyName
	}

	// Проверяем возраст
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}

	// Проверяем email
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

// String returns a string representation of the user
func (u *User) String() string {
    return "User{Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email + "}"
}

// IsValidEmail checks if the email format is valid
func IsValidEmail(email string) bool {
    email = strings.TrimSpace(email)
    if email == "" {
        return false
    }

    // Проверяем наличие пробелов в email
    if strings.ContainsAny(email, " \t\n\r") {
        return false
    }

    parts := strings.Split(email, "@")
    if len(parts) != 2 {
        return false
    }

    if parts[0] == "" || parts[1] == "" {
        return false
    }

    // Проверяем наличие точки в доменной части
    if !strings.Contains(parts[1], ".") {
        return false
    }

    return true
}