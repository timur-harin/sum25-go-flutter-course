package user

import (
	"errors"
	"fmt"
)

var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

type User struct {
	Name  string
	Age   int
	Email string
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

func (u *User) Validate() error {
	if u.Name == "" || len(u.Name) > 30 {
		return ErrInvalidName
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
	return fmt.Sprintf("Name: %s, Age: %d, Email: %s", u.Name, u.Age, u.Email)
}

func IsValidEmail(email string) bool {
	at := 0
	for _, ch := range email {
		if ch == '@' {
			at++
		}
	}
	if at != 1 {
		return false
	}

	if len(email) == 0 || email[0] == '@' || email[len(email)-1] == '@' {
		return false
	}

	atIndex := -1
	for i, ch := range email {
		if ch == '@' {
			atIndex = i
			break
		}
	}
	if atIndex == -1 || atIndex == len(email)-1 {
		return false
	}
	domainPart := email[atIndex+1:]
	if len(domainPart) == 0 || !containsDot(domainPart) {
		return false
	}

	return true
}

func containsDot(s string) bool {
	for _, ch := range s {
		if ch == '.' {
			return true
		}
	}
	return false
}

func IsValidName(name string) bool {
	return name != "" && len(name) <= 30
}

func IsValidAge(age int) bool {
	return age >= 0 && age <= 150
}
