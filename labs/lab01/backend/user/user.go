package user

import (
	"errors";
	"strings";
	"fmt"
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
	user := User{
		Name: name,
		Age: age,
		Email: email,
	}
	res := user.Validate()
	if res == nil {
		return &user, nil
	} else {
		return &user, res
	}
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if len(u.Name) == 0 {
		return ErrEmptyName
	}
	if IsValidEmail(u.Email) == false {
		return ErrInvalidEmail
	}
	if u.Age < 0 || u.Age > 100 {
		return ErrInvalidAge
	}
	return nil
}

// String returns a string representation of the user, formatted as "Name: <name>, Age: <age>, Email: <email>"
func (u *User) String() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

// NewUser creates a new user with validation, returns an error if the user is not valid
func NewUser(name string, age int, email string) (*User, error) {
	// TODO: Implement this function
	return nil, nil
}

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	return strings.Contains(email, "@") && strings.Contains(email, ".com")
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	// TODO: Implement this function
	return false
}