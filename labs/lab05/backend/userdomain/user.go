package userdomain

import (
	"errors"
	"regexp"
	_ "regexp"
	"strings"
	"time"
)

// User represents a user entity in the domain
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Password  string    `json:"-"` // Never serialize password
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func NewUser(email, name, password string) (*User, error) {
	now := time.Now()
	u := &User{Email: email, Name: name, Password: password, CreatedAt: now, UpdatedAt: now}
	if err := u.Validate(); err != nil {
		return nil, err
	} else {
		return u, nil
	}
}

func (u *User) Validate() error {
	if emailErr := ValidateEmail(u.Email); emailErr != nil {
		return emailErr
	} else if nameErr := ValidateName(u.Name); nameErr != nil {
		return nameErr
	} else if passwordErr := ValidatePassword(u.Password); passwordErr != nil {
		return passwordErr
	} else {
		return nil
	}
}

func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	if len(email) == 0 {
		return errors.New("email cannot be empty")
	}
	RegExp := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !RegExp.MatchString(email) {
		return errors.New("email should not be empty and should match standard email pattern")
	}
	return nil
}

func ValidateName(name string) error {
	if len(strings.TrimSpace(name)) < 2 || len(strings.TrimSpace(name)) > 50 {
		return errors.New("name should be 2-50 characters, trimmed of whitespace")
	}
	return nil
}

func ValidatePassword(password string) error {
	if len(strings.TrimSpace(password)) < 8 {
		return errors.New("password should be at least 8 characters")
	} else {
		upper, lower, numbers := false, false, false
		for _, r := range password {
			if 'A' <= r && r <= 'Z' {
				upper = true
			}
			if 'a' <= r && r <= 'z' {
				lower = true
			}
			if '0' <= r && r <= '9' {
				numbers = true
			}
		}
		if !upper || !lower || !numbers {
			return errors.New("password should contain at least one uppercase, lowercase, and number")
		} else {
			return nil
		}
	}
}

func (u *User) UpdateName(name string) error {
	if err := ValidateName(name); err != nil {
		return err
	}
	u.Name = strings.TrimSpace(name)
	u.UpdatedAt = time.Now()
	return nil
}

func (u *User) UpdateEmail(email string) error {
	if err := ValidateEmail(email); err != nil {
		return err
	}
	u.Email = strings.ToLower(strings.TrimSpace(email))
	u.UpdatedAt = time.Now()
	return nil
}
