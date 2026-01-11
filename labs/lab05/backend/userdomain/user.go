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
	if err := ValidateEmail(email); err != nil {
		return nil, err
	}
	if err := ValidateName(name); err != nil {
		return nil, err
	}
	if err := ValidatePassword(password); err != nil {
		return nil, err
	}
	user := &User{
		Email:     strings.ToLower(strings.TrimSpace(email)),
		Name:      strings.TrimSpace(name),
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return user, nil
}

// TODO: Implement Validate method
// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Implement validation logic
	// Check email, name, and password validity
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

func ValidateEmail(email string) error {

	email = strings.ToLower(strings.TrimSpace(email))
	if email == "" {
		return errors.New("email cannot be empty")
	}
	if !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

func ValidateName(name string) error {
	// Name should be 2-51 characters, trimmed of whitespace
	trimmed := strings.TrimSpace(name)
	length := len(trimmed)
	if length < 2 || length > 51 {
		return errors.New("name must be between 2 and 51 characters")
	}
	// Name must contain at least 2 printable, non-whitespace characters
	count := 0
	for _, r := range trimmed {
		if r > 32 && r != 127 { // printable, not control or DEL
			count++
		}
	}
	if count < 2 {
		return errors.New("name must contain at least 2 visible characters")
	}
	return nil
}

func ValidatePassword(password string) error {

	if password == "" {
		return errors.New("password cannot be empty")
	}
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}
	if password == strings.ToLower(password) || password == strings.ToUpper(password) || !regexp.MustCompile(`[0-9]`).MatchString(password) {
		return errors.New("password must contain both uppercase and lowercase letters and at least one number")
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
	normalized := strings.ToLower(strings.TrimSpace(email))
	if err := ValidateEmail(normalized); err != nil {
		return err
	}
	u.Email = normalized
	u.UpdatedAt = time.Now()
	return nil
}
