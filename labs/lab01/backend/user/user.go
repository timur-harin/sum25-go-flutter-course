package user

import (
	"errors"
	"fmt"
	"strings"
)

var (
	ErrInvalidEmail = errors.New("invalid email format")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrEmptyName    = errors.New("name cannot be empty")
)

type User struct {
	Name  string
	Age   int
	Email string
}

func NewUser(name string, age int, email string) (*User, error) {
	u := &User{Name: name, Age: age, Email: email}
	if err := u.Validate(); err != nil {
		return nil, err
	}
	return u, nil
}

func (u *User) Validate() error {
	if u.Name == "" {
		return ErrEmptyName
	}
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}
	return nil
}

func (u *User) String() string {
	return fmt.Sprintf("%s (%d) <%s>", u.Name, u.Age, u.Email)
}

func IsValidEmail(email string) bool {
	return strings.Contains(email, "@") && strings.Contains(email, ".")
}
