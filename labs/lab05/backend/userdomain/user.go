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

// NewUser creates a new user with validation
// Requirements:
// - Email must be valid format
// - Name must be 2-51 characters
// - Password must be at least 8 characters
// - CreatedAt and UpdatedAt should be set to current time
func NewUser(email, name, password string) (*User, error) {
	var user = &User{
		ID:        0,
		Email:     email,
		Name:      name,
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	err := user.Validate()
	if err != nil {
		return nil, err
	}
	return user, err
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if err := ValidateName(u.Name); err != nil {
		return err
	}
	if err := ValidateEmail(u.Email); err != nil {
		return err
	}
	if err := ValidatePassword(u.Password); err != nil {
		return err
	}
	return nil
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	email = strings.ToLower(email)
	isValid, err := regexp.MatchString("^[a-z0-9._%+\\-]+@[a-z0-9.\\-]+\\.[a-z]{2,4}$", email)
	if !isValid || email == "" {
		return errors.New("invalid email")
	}
	return err
}

// ValidateName checks if name is valid
func ValidateName(name string) error {
	name = strings.TrimSpace(name)
	if len(name) < 2 || len(name) > 50 {
		return errors.New("name must be 2-50 characters")
	}
	return nil
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	uppercase := false
	lowercase := false
	number := false
	for _, ch := range password {
		if ch >= 65 && ch <= 90 {
			uppercase = true
		}
		if ch >= 97 && ch <= 122 {
			lowercase = true
		}
		if ch >= 48 && ch <= 57 {
			number = true
		}
	}
	if !uppercase || !lowercase || !number {
		return errors.New("password contain at least one uppercase, lowercase, and number")
	}
	return nil
}

// UpdateName updates the user's name with validation
func (u *User) UpdateName(name string) error {
	if err := ValidateName(name); err != nil {
		return err
	}
	u.Name = strings.TrimSpace(name)
	u.UpdatedAt = time.Now()
	return nil
}

// UpdateEmail updates the user's email with validation
func (u *User) UpdateEmail(email string) error {
	if err := ValidateEmail(email); err != nil {
		return err
	}
	u.Email = strings.ToLower(strings.TrimSpace(email))
	u.UpdatedAt = time.Now()
	return nil
}
