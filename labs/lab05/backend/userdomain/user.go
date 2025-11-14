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

func NewUser(email, name, password string) (*User, error) {
	if err := ValidateEmail(email); err != nil {
		return nil, err
	}
	if err := ValidateName(name); err != nil {
		return nil, err
	}
	if err := ValidatePassword(password); err != nil {
		return nil, err
	}

	timeNow := time.Now()

	user := &User{
		Email:     strings.ToLower(strings.TrimSpace(email)),
		Name:      strings.TrimSpace(name),
		Password:  strings.TrimSpace(password),
		CreatedAt: timeNow,
		UpdatedAt: timeNow,
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

func ValidateEmail(email string) error {
	validEmail := strings.ToLower(strings.TrimSpace(email))
	if !emailRegex.MatchString(validEmail) {
		return ErrInvEmail
	}
	return nil
}

func ValidateName(name string) error {
	trimmedName := strings.TrimSpace(name)

	if len(trimmedName) < 2 || len(trimmedName) > 50 {
		return ErrInvName
	}
	return nil
}

func ValidatePassword(password string) error {
	valid := len(password) >= 8
	valid = valid && strings.ContainsAny(password, uppsercase)
	valid = valid && strings.ContainsAny(password, lowercase)
	valid = valid && strings.ContainsAny(password, numbers)

	if !valid {
		return ErrInvPassword
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

var (
	uppsercase = "QWERTYUIOPASDFGHJKLZXCVBNM"
	lowercase  = "qwertyuiopasdfghjklzxcvbnm"
	numbers    = "1234567890"
)

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)

var (
	ErrInvPassword = errors.New("password should be at least 8 characters long, contain at least one uppercase letter, lowercase letter and a number")
	ErrInvName     = errors.New("name should be from 2 to 50 characters long")
	ErrInvEmail    = errors.New("invalid email format")
)
