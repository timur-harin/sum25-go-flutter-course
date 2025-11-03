package userdomain

import (
	"lab05/security"
	_ "regexp"
	"strings"
	"time"
	"unicode"

	"github.com/go-playground/validator/v10"
)

var (
	validate = validator.New()
)

// User represents a user entity in the domain
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"     validate:"email,required"`
	Name      string    `json:"name"      validate:"min=2,max=50,required"`
	Password  string    `json:"-"         validate:"min=8,required"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// NewUser creates a new user with validation
// - Email must be valid format
// - Name must be 2-50 characters
// - Password must be at least 8 characters and meet complexity requirements
// - CreatedAt and UpdatedAt should be set to current time
func NewUser(email, name, password string) (*User, error) {
	// Normalize inputs
	email = strings.ToLower(strings.TrimSpace(email))
	name = strings.TrimSpace(name)

	// Validate password complexity
	if err := ValidatePassword(password); err != nil {
		return nil, err
	}

	user := &User{
		Email:     email,
		Name:      name,
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	if err := validate.Struct(user); err != nil {
		return nil, err
	}
	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	return validate.Struct(u)
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	return validate.Var(email, "email,required")
}

// ValidateName checks if name is valid
func ValidateName(name string) error {
	name = strings.TrimSpace(name)
	return validate.Var(name, "min=2,max=50,required")
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return security.ErrShortPassword
	}
	
	hasDigit := false
	hasLower := false
	hasUpper := false
	
	for _, c := range password {
		if unicode.IsNumber(c) {
			hasDigit = true
		} else if unicode.IsLetter(c) {
			if unicode.IsUpper(c) {
				hasUpper = true
			} else if unicode.IsLower(c) {
				hasLower = true
			}
		}
	}
	if !hasLower { return security.ErrNoPasswordLower }
	if !hasUpper { return security.ErrNoPasswordUpper }
	if !hasDigit { return security.ErrNoPasswordDigit }
	
	return nil
}

// UpdateName updates the user's name with validation
func (u *User) UpdateName(name string) error {
	name = strings.TrimSpace(name)
	if err := ValidateName(name); err != nil {
		return err
	}
	u.Name = name
	u.UpdatedAt = time.Now()
	return nil
}

// UpdateEmail updates the user's email with validation
func (u *User) UpdateEmail(email string) error {
	email = strings.ToLower(strings.TrimSpace(email))
	if err := ValidateEmail(email); err != nil {
		return err
	}
	u.Email = email
	u.UpdatedAt = time.Now()
	return nil
}
