package security

import (
	"errors"
	_ "regexp"
	"unicode"

	"golang.org/x/crypto/bcrypt"
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
		return "", errors.New("password can't be empty")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)

	if err != nil {
		return "", err
	}

	return string(hash), nil
}

// VerifyPassword checks if password matches hash
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}

	if bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) != nil {
		return false
	}

	return true
}

// TODO: Implement ValidatePassword function
// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	var hasLetter, hasDigit bool

	for _, ch := range password {
		switch {
		case unicode.IsLetter(ch):
			hasLetter = true
		case unicode.IsDigit(ch):
			hasDigit = true
		}
	}

	if !hasDigit {
		return errors.New("password does not have a digit")
	}

	if !hasLetter {
		return errors.New("password must have at least one letter")
	}

	return nil
}
