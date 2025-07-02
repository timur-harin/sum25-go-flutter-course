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

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.Name == ""{
		return ErrInvalidName
	}
	if u.Age < 0 || u.Age > 150{
		return ErrInvalidAge
	}
	if !IsValidEmail(u.Email){
		return ErrInvalidEmail
	}
	return nil
}

// String returns a string representation of the user, formatted as "Name: <name>, Age: <age>, Email: <email>"
func (u *User) String() string {
	return "Name" + u.Name + "Age" + fmt.Sprint(u.Age) + "Email" + u.Email
}


// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	var pattern string = "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$"
	matched, _ := regexp.MatchString(pattern, email);
	return matched
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	// TODO: Implement this function
	return false
}