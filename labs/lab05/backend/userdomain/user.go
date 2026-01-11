package userdomain

import (
	"errors"
	_ "regexp"
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

// NewUser creates a new user with validation
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

	now := time.Now()

	user := &User{
		Email:     email,
		Name:      name,
		Password:  password,
		CreatedAt: now,
		UpdatedAt: now,
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
	email = strings.TrimSpace(email)
	if email == "" {
		return errors.New("invalid email format")
	}

	pos := strings.Index(email, "@")
	if pos == -1 {
		return errors.New("invalid email format")
	}

	if strings.Count(email, "@") != 1 {
		return errors.New("invalid email format")
	}

	if pos == 0 || pos == len(email)-1 {
		return errors.New("invalid email format")
	}

	if strings.Contains(email, " ") {
		return errors.New("invalid email format")
	}

	domain := email[pos+1:]
	if !strings.Contains(domain, ".") {
		return errors.New("invalid email format")
	}

	return nil
}

func ValidateName(name string) error {
	if len(name) < 2 || len(name) > 50 {
		return errors.New("invalid name lenght")
	}
	if (strings.TrimSpace(name)) == "" {
		return errors.New("name should not be empty")
	}
	return nil
}

func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("invalid password lenght")
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

		if hasUpper && hasLower && hasNumber {
			break
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
