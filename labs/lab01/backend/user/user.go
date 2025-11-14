package user

import (
	"errors"
	"regexp"
	"strconv"
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

func (u *User) Validate() error {
	switch {
	case !CheckName(u.Name):
		return ErrInvalidName
	case !CheckAge(u.Age):
		return ErrInvalidAge
	case !CheckEmail(u.Email):
		return ErrInvalidEmail
	default:
		return nil
	}
}
func (u *User) String() string {
	return "Name: " + u.Name + ", Age: " + strconv.Itoa(u.Age) + ", Email: " + u.Email
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
func CheckEmail(email string) bool {
	re := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	return re.MatchString(email)
}
func CheckName(name string) bool {
	return len(name) > 0 && len(name) <= 30
}
func CheckAge(age int) bool {
	return age >= 0 && age <= 150
}
