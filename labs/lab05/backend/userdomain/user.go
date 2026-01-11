package userdomain

import (
	"errors"
	"regexp"
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

func NewUser(email, name, password string) (*User, error) {
	time := time.Now()
	user := &User{Name: name, Email: email, Password: password, CreatedAt: time, UpdatedAt: time}
	if err := user.Validate(); err != nil {
		return nil, err
	}
	return user, nil
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

func ValidateEmail(email string) error {
	if email == "" || !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).MatchString(email) {
		return errors.New("invalid email")
	}
	return nil
}

// TODO: Implement ValidateName function
// ValidateName checks if name is valid
func ValidateName(name string) error {
	trimmed := strings.TrimSpace(name)

	if trimmed == "" {
		return errors.New("name cannot be empty or only spaces")
	}

	// Check length (2-50 characters)
	if len(trimmed) < 2 || len(trimmed) > 50 {
		return errors.New("name must be 2-50 characters")
	}

	return nil
}

func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	var hasLower bool = false
	var hasUpper bool = false
	var hasNumber bool = false
	for _, r := range password {
		if unicode.IsLower(r) {
			hasLower = true
		} else if unicode.IsUpper(r) {
			hasUpper = true
		} else if unicode.IsNumber(r) {
			hasNumber = true
		}
	}
	if !hasLower {
		return errors.New("password has to contain as least one lower character")
	}
	if !hasUpper {
		return errors.New("password has to contain as least one upper character")
	}
	if !hasNumber {
		return errors.New("password has to contain as least one number character")
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
	normalizedEmail := strings.ToLower(strings.TrimSpace(email))
	if err := ValidateEmail(normalizedEmail); err != nil {
		return err
	}
	u.Email = normalizedEmail
	u.UpdatedAt = time.Now()
	return nil
}
