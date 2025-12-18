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

// NewUser creates a new user with validation
// Requirements:
// - Email must be valid format
// - Name must be 2-50 characters
// - Password must be at least 8 characters and meet complexity
// - CreatedAt and UpdatedAt set to current time
func NewUser(email, name, password string) (*User, error) {
	email = strings.ToLower(strings.TrimSpace(email))
	name = strings.TrimSpace(name)

	if err := ValidateEmail(email); err != nil {
		return nil, err
	}
	if err := ValidateName(name); err != nil {
		return nil, err
	}
	if err := ValidatePassword(password); err != nil {
		return nil, err
	}

	now := time.Now()
	user := &User{Email: email, Name: name, Password: password, CreatedAt: now, UpdatedAt: now}
	return user, nil
}

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

// ValidateEmail checks if email format is valid
// Email should not be empty and match standard pattern
func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	if email == "" {
		return errors.New("email must not be empty")
	}
	pattern := `^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$`
	re := regexp.MustCompile(pattern)
	if !re.MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

// ValidateName checks if name is valid
func ValidateName(name string) error {
	trimmed := strings.TrimSpace(name)
	if len(trimmed) < 2 || len(trimmed) > 50 {
		return errors.New("name must be between 2 and 50 characters")
	}
	return nil
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}
	upper, _ := regexp.MatchString(`[A-Z]`, password)
	lower, _ := regexp.MatchString(`[a-z]`, password)
	digit, _ := regexp.MatchString(`[0-9]`, password)
	if !upper || !lower || !digit {
		return errors.New("password must contain at least one uppercase letter, one lowercase letter, and one number")
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
	// Normalize before validation
	normalized := strings.ToLower(strings.TrimSpace(email))
	if err := ValidateEmail(normalized); err != nil {
		return err
	}
	u.Email = normalized
	u.UpdatedAt = time.Now()
	return nil
}
