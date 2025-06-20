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
	var user = User{name, age, email}
	err := user.Validate()
	if err != nil {
		return nil, err
	}
	return &User{name, age, email}, nil
}

func (u *User) Validate() error {

	if len(u.Name) == 0 {
		return ErrEmptyName
	}
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}
	if !IsValidEmail(u.Email) == true {
		return ErrInvalidEmail
	}
	return nil
}

func (u *User) String() string {
	s := fmt.Sprintf("%s %d %s", u.Name, u.Age, u.Email)
	return s
}

func IsValidEmail(email string) bool {
	if email == "" || len(email) == 0 {
		return false
	}
	if strings.Contains(email, "@") == false {
		return false
	}
	return true
}
