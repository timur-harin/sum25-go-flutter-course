package userdomain

import (
	"errors"
	"regexp"
	_ "regexp"
	"strings"
	"time"
	"unicode"
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
// - Name must be 2-50 characters
// - Password must be at least 8 characters
// - CreatedAt and UpdatedAt should be set to current time
func NewUser(email, name, password string) (*User, error) {
	user := &User{
		Email:     email,
		Name:      name,
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := user.Validate(); err != nil {
		return nil, err
	}

	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if err := ValidateEmail(u.Email); err != nil {
		return err
	}

	u.Email = strings.TrimSpace(u.Email)

	if err := ValidateName(u.Name); err != nil {
		return err
	}

	u.Name = strings.TrimSpace(u.Name)

	if err := ValidatePassword(u.Password); err != nil {
		return err
	}

	return nil
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	const emailRegexPattern = `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(emailRegexPattern)

	if !re.MatchString(strings.TrimSpace(email)) {
		return errors.New("invalid email format")
	}

	return nil
}

// ValidateName checks if name is valid
func ValidateName(name string) error {

	if 2 > len(strings.TrimSpace(name)) || 50 < len(strings.TrimSpace(name)) {
		return errors.New("invalid name")
	}

	return nil
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	// Password should be at least 8 characters
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}
	// Should contain at least one uppercase, lowercase, and number
	var hasUpper, hasLower, hasDigit bool

	for _, ch := range password {
		switch {
		case unicode.IsUpper(ch):
			hasUpper = true
		case unicode.IsLower(ch):
			hasLower = true
		case unicode.IsDigit(ch):
			hasDigit = true
		}
	}

	if !hasUpper {
		return errors.New("password must contain at least one uppercase letter")
	}

	if !hasLower {
		return errors.New("password must contain at least one lowecase letter")
	}

	if !hasDigit {
		return errors.New("password must contain at least one digit")
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
