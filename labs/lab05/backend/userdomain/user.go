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
	Password  string    `json:"-"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// NewUser creates a new user with validation
func NewUser(email, name, password string) (*User, error) {
	// Сначала нормализуем данные
	normalizedEmail := strings.ToLower(strings.TrimSpace(email))
	trimmedName := strings.TrimSpace(name)

	user := &User{
		Email:    normalizedEmail,
		Name:     trimmedName,
		Password: password,
	}

	// Теперь валидируем уже чистые данные
	if err := user.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()
	user.CreatedAt = now
	user.UpdatedAt = now

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

var emailRegex = regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	if email == "" {
		return errors.New("email cannot be empty")
	}
	if !emailRegex.MatchString(email) {
		return errors.New("invalid email format")
	}
	return nil
}

// ValidateName checks if name is valid
func ValidateName(name string) error {
	trimmedName := strings.TrimSpace(name)
	if len(trimmedName) < 2 {
		return errors.New("name must be at least 2 characters long")
	}
	if len(trimmedName) > 50 {
		return errors.New("name must not exceed 50 characters")
	}
	return nil
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters long")
	}

	var (
		hasUpper  bool
		hasLower  bool
		hasNumber bool
	)

	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		}
	}

	if !hasUpper || !hasLower || !hasNumber {
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
