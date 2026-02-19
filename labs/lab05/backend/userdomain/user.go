package userdomain

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"
	"unicode/utf8"
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

// TODO: Implement NewUser function
// NewUser creates a new user with validation
// Requirements:
// - Email must be valid format
// - Name must be 2-51 characters
// - Password must be at least 8 characters
// - CreatedAt and UpdatedAt should be set to current time
func NewUser(email, name, password string) (*User, error) {
	// TODO: Implement this function
	// Hint: Use ValidateEmail, ValidateName, ValidatePassword helper functions
	user := User{
		Name:      name,
		Email:     email,
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := user.Validate(); err != nil {
		return nil, fmt.Errorf("failed while creating a new user: %w", err)
	}

	return &user, nil
}

// TODO: Implement Validate method
// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement validation logic
	// Check email, name, and password validity
	if err := ValidateEmail(u.Email); err != nil {
		return err
	} else if err := ValidateName(u.Name); err != nil {
		return err
	} else if err := ValidatePassword(u.Password); err != nil {
		return err
	}

	return nil
}

// TODO: Implement ValidateEmail function
// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	// TODO: Implement email validation
	// Use regex pattern to validate email format
	// Email should not be empty and should match standard email pattern
	if email == "" {
		return errors.New("email cannot be empty")
	}

	email = strings.TrimSpace(email)
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(email) {
		return errors.New("invalid email")
	}

	return nil
}

// TODO: Implement ValidateName function
// ValidateName checks if name is valid
func ValidateName(name string) error {
	// TODO: Implement name validation
	// Name should be 2-50 characters, trimmed of whitespace
	// Should not be empty after trimming
	name = strings.TrimSpace(name)

	if name == "" {
		return errors.New("name cannot be empty")
	} else if utf8.RuneCountInString(name) < 2 || utf8.RuneCountInString(name) > 50 {
		return errors.New("name should be 2-50 chars long")
	}

	return nil
}

// TODO: Implement ValidatePassword function
// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	// TODO: Implement password validation
	// Password should be at least 8 characters
	// Should contain at least one uppercase, lowercase, and number
	if utf8.RuneCountInString(password) < 8 {
		return errors.New("password should be at least 8 chars long")
	} else if hasUpper := regexp.MustCompile(`[A-Z]`); !hasUpper.MatchString(password) {
		return errors.New("password should contain at least one uppercase letter")
	} else if hasLower := regexp.MustCompile(`[a-z]`); !hasLower.MatchString(password) {
		return errors.New("password should contain at least one lower letter")
	} else if hasNumber := regexp.MustCompile(`[0-9]`); !hasNumber.MatchString(password) {
		return errors.New("password should contain at least one number")
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
