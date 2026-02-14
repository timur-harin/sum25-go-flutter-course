package user

import (
	"errors"
	"fmt"
	"regexp"
)

var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

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

func (u *User) String() string {
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

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

func IsValidEmail(email string) bool {
	return emailRegex.MatchString(email)
}

func IsValidName(name string) bool {
	return len(name) >= 1 && len(name) <= 30
}

func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
