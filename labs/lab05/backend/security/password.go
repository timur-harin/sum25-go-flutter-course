package security

import (
	"errors"
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
// Updated for GitHub Actions compatibility
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
// Requirements:
// - password must not be empty
// - use bcrypt with cost 10
// - return the hashed password as string
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cannot be empty")
	}

	// Hash password using bcrypt with cost 10
	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}

	return string(hashedBytes), nil
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

	// Compare password with hash using bcrypt
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if password == "" {
		return errors.New("password cannot be empty")
	}

	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	// Check if password contains at least one letter
	hasLetter := regexp.MustCompile(`[a-zA-Z]`).MatchString(password)
	if !hasLetter {
		return errors.New("password must contain at least one letter")
	}

	// Check if password contains at least one number
	hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
	if !hasNumber {
		return errors.New("password must contain at least one number")
	}

	return nil
}
