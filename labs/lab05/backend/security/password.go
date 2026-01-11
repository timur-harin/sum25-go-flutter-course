package security

import (
	"errors"
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	// Return a new PasswordService instance
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
// Requirements:
// - password must not be empty
// - use bcrypt with cost 10
// - return the hashed password as string
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password must not be empty")
	}
	hashedPass, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

	return string(hashedPass), err
}

// VerifyPassword checks if password matches hash
// Requirements:
// - password and hash must not be empty
// - return true if password matches hash
// - return false if password doesn't match
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)); err != nil {
		return false
	}
	// Return true only if passwords match exactly
	return true
}

// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	if password == "" {
		return errors.New("password must not be empty")
	}

	matched, err := regexp.Match(`[A-Za-z]`, []byte(password))
	if err != nil || !matched {
		return errors.New("password must contain at least one letter")
	}

	matched, err = regexp.Match(`[1-9]`, []byte(password))
	if err != nil || !matched {
		return errors.New("password must contain at least one digit")
	}

	return nil
}
