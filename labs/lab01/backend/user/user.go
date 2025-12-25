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

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

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
	u := &User{Name: name, Age: age, Email: email}
	if err := u.Validate(); err != nil {
		return nil, err
	}
	return u, nil
}

func IsValidEmail(email string) bool {
	return emailRegex.MatchString(email)
}

func IsValidName(name string) bool {
	length := len(name)
	return length >= 1 && length <= 30
}

func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
