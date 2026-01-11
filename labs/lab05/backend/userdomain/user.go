package userdomain

import (
	"errors"
	"regexp"
	"strings"
	"time"
)

// User represents a user entity in the domain
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Password  string    `json:"-"`
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
	// Create a new user instance
	u := &User{
		Email:     strings.ToLower(strings.TrimSpace(email)),
		Name:      strings.TrimSpace(name),
		Password:  password, // Password should be hashed in production code
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := u.Validate(); err != nil {
		return nil, err
	}
	return u, nil
}

func (u *User) Validate() error {
	if err := ValidateEmail(u.Email); err != nil {
		return err
	}
	if err := ValidateName(u.Name); err != nil {
		return err
	}
	if err := ValidatePassword(u.Password); err != nil {
		return err
	}
	return nil
}

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

func ValidateEmail(email string) error {
	if !emailRegex.MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

func ValidateName(name string) error {
	trimmedName := strings.TrimSpace(name)
	if trimmedName == "" {
		return errors.New("name cannot be empty")
	}
	if len(trimmedName) < 2 || len(trimmedName) > 50 {
		return errors.New("name must be between 2 and 50 characters")
	}
	return nil
}

func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}

	if !strings.ContainsAny(password, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") ||
		!strings.ContainsAny(password, "abcdefghijklmnopqrstuvwxyz") ||
		!strings.ContainsAny(password, "0123456789") {
		return errors.New("password must contain at least one uppercase letter, one lowercase letter, and one number")
	}
	return nil
}

// UpdateName updates the user's name with validation
func (u *User) UpdateName(name string) error {
	trimmedName := strings.TrimSpace(name)
	if err := ValidateName(trimmedName); err != nil {
		return err
	}
	u.Name = trimmedName
	u.UpdatedAt = time.Now()
	return nil
}

// UpdateEmail updates the user's email with validation
func (u *User) UpdateEmail(email string) error {
	normalizedEmail := strings.ToLower(strings.TrimSpace(email))
	if err := ValidateEmail(normalizedEmail); err != nil {
		return err
	}
	u.Email = normalizedEmail
	u.UpdatedAt = time.Now()
	return nil
}
