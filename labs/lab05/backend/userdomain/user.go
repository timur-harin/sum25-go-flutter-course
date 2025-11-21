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
	trimmedEmail := strings.TrimSpace(email)
	trimmedName := strings.TrimSpace(name)

	if err := ValidateEmail(trimmedEmail); err != nil {
		return nil, err
	}
	if err := ValidateName(trimmedName); err != nil {
		return nil, err
	}
	if err := ValidatePassword(password); err != nil {
		return nil, err
	}

	now := time.Now()
	user := &User{
		Email:     trimmedEmail,
		Name:      trimmedName,
		Password:  password,
		CreatedAt: now,
		UpdatedAt: now,
	}
	return user, nil
}

// TODO: Implement Validate method
// Validate checks if the user data is valid
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

// TODO: Implement ValidateEmail function
// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	if email == "" {
		return errors.New("email must not be empty")
	}
	// Simple email regex pattern
	pattern := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(pattern)
	if !re.MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

// TODO: Implement ValidateName function
// ValidateName checks if name is valid
func ValidateName(name string) error {
	trimmed := strings.TrimSpace(name)
	if trimmed == "" {
		return errors.New("name must not be empty")
	}
	if len([]rune(trimmed)) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if len([]rune(trimmed)) > 50 {
		return errors.New("name must be at most 50 characters")
	}
	return nil
}

// TODO: Implement ValidatePassword function
// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	password = strings.TrimSpace(password)
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}
	hasUpper := false
	hasLower := false
	hasNumber := false
	for _, c := range password {
		switch {
		case c >= 'A' && c <= 'Z':
			hasUpper = true
		case c >= 'a' && c <= 'z':
			hasLower = true
		case c >= '0' && c <= '9':
			hasNumber = true
		}
	}
	if !hasUpper {
		return errors.New("password must contain at least one uppercase letter")
	}
	if !hasLower {
		return errors.New("password must contain at least one lowercase letter")
	}
	if !hasNumber {
		return errors.New("password must contain at least one number")
	}
	return nil
}

// UpdateName updates the user's name with validation
func (u *User) UpdateName(name string) error {
	trimmed := strings.TrimSpace(name)
	if err := ValidateName(trimmed); err != nil {
		return err
	}
	u.Name = trimmed
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
