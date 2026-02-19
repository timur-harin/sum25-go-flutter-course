package security

import (
	"errors"
	"regexp"
	"unicode/utf8"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// TODO: Implement NewPasswordService function
// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	// TODO: Implement this function
	// Return a new PasswordService instance
	return &PasswordService{}
}

// TODO: Implement HashPassword method
// HashPassword hashes a password using bcrypt
// Requirements:
// - password must not be empty
// - use bcrypt with cost 10
// - return the hashed password as string
func (p *PasswordService) HashPassword(password string) (string, error) {
	// TODO: Implement password hashing
	// Use golang.org/x/crypto/bcrypt.GenerateFromPassword
	if password == "" {
		return "", errors.New("password cannot be empty")
	}

	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)

	return string(bytes), err
}

// TODO: Implement VerifyPassword method
// VerifyPassword checks if password matches hash
// Requirements:
// - password and hash must not be empty
// - return true if password matches hash
// - return false if password doesn't match
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	// TODO: Implement password verification
	// Use bcrypt.CompareHashAndPassword
	// Return true only if passwords match exactly
	if password == "" || hash == "" {
		return false
	}

	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// TODO: Implement ValidatePassword function
// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	// TODO: Implement password validation
	// Check length and basic complexity requirements
	if utf8.RuneCountInString(password) < 6 {
		return errors.New("password should be at least 6 chars long")
	}
	if hasLetter := regexp.MustCompile(`[a-zA-Z]`); !hasLetter.MatchString(password) {
		return errors.New("password should contain a letter")
	}
	if hasNumber := regexp.MustCompile(`[0-9]`); !hasNumber.MatchString(password) {
		return errors.New("password should contain a number")
	}

	return nil
}
