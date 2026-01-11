package security

import (
	"errors"
	"golang.org/x/crypto/bcrypt"
	"unicode"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cannot be empty")
	}
	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost) // cost 10
	if err != nil {
		return "", err
	}
	return string(hashed), nil
}

// VerifyPassword checks if password matches hash
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword checks if password meets basic requirements
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters")
	}

	var hasLetter, hasDigit bool
	for _, r := range password {
		if unicode.IsLetter(r) {
			hasLetter = true
		} else if unicode.IsDigit(r) {
			hasDigit = true
		}
	}

	if !hasLetter {
		return errors.New("password must contain at least one letter")
	}
	if !hasDigit {
		return errors.New("password must contain at least one number")
	}

	return nil
}
