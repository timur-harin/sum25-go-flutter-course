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
	// TODO: Implement this function
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

	user := &User{
		Email:     strings.ToLower(strings.TrimSpace(email)),
		Name:      strings.TrimSpace(name),
		Password:  password, // Пароль будет захеширован позже
		CreatedAt: now,
		UpdatedAt: now,
	}

	return user, nil
}

// TODO: Implement Validate method
// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement validation logic
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
	// TODO: Implement email validation
	email = strings.TrimSpace(email)
	if email == "" {
		return errors.New("email cannot be empty")
	}

	regex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !regex.MatchString(email) {
		return errors.New("invalid email format")
	}

	return nil
}

// TODO: Implement ValidateName function
// ValidateName checks if name is valid
func ValidateName(name string) error {
	// TODO: Implement name validation
	name = strings.TrimSpace(name)
	if len(name) < 2 || len(name) > 50 {
		return errors.New("name must be between 2 and 50 characters")
	}
	return nil
}

// TODO: Implement ValidatePassword function
// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	// TODO: Implement password validation
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}

	hasUpper := false
	hasLower := false
	hasNumber := false

	for _, ch := range password {
		switch {
		case 'A' <= ch && ch <= 'Z':
			hasUpper = true
		case 'a' <= ch && ch <= 'z':
			hasLower = true
		case '0' <= ch && ch <= '9':
			hasNumber = true
		}
	}

	if !hasUpper || !hasLower || !hasNumber {
		return errors.New("password must contain upper, lower, and number")
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
