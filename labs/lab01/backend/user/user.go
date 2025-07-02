package user

import (
	"fmt"
	"errors"
	"regexp"
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
	return "Name: " + u.Name + ", Age: " + fmt.Sprint(u.Age) + ", Email: " + u.Email
}
// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	u := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}
	if err := u.Validate(); err != nil{
		return nil, err
	}
	return u, nil
}

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	var pattern string = "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$"
	matched, _ := regexp.MatchString(pattern, email);
	return matched
}



// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	return !(name=="" || len(name) > 30 )
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	
	return  !(age <= 0 || age > 150)
}


