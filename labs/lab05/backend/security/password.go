package security

import (
	"errors"
	_ "regexp"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

func hasNumber(s string) bool {
	for _, r := range s {
		if unicode.IsDigit(r) {
			return true
		}
	}
	return false
}

func hasLetter(s string) bool {
	for _, r := range s {
		if unicode.IsLetter(r) {
			return true
		}
	}
	return false
}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
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
		return "", errors.New("password must not be empty")
	}
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

// TODO: Implement VerifyPassword method
// VerifyPassword checks if password matches hash
// Requirements:
// - password and hash must not be empty
// - return true if password matches hash
// - return false if password doesn't match
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	// Use bcrypt.CompareHashAndPassword
	// Return true only if passwords match exactly
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 chartacter")
	}
	if !(hasLetter(password) && hasNumber(password)) {
		return errors.New("password must Contains at least one letter and one number")
	}
	return nil
}
