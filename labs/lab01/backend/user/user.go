package user

import (
	"errors"
	"fmt"
	"regexp"
)

var (
	// ErrInvalidEmail is returned when the email format is invalid
	ErrInvalidEmail = errors.New("invalid email format")
	// ErrInvalidAge is returned when the age is invalid
	ErrInvalidAge = errors.New("invalid age: must be between 0 and 150")
	// ErrEmptyName is returned when the name is empty
	ErrEmptyName = errors.New("name cannot be empty")
)

type User struct {
	Name  string
	Age   int
	Email string
}

func NewUser(name string, age int, email string) (*User, error) {
	u := &User{
		Name:  name,
		Age:   age,
		Email: email,
	}
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
	return fmt.Sprintf("User(Name: %s, Age: %d, Email: %s)", u.Name, u.Age, u.Email)
}

func IsValidEmail(email string) bool {
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}
