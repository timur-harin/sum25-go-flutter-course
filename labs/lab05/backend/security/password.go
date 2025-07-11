package security

import (
	"errors"
	"regexp"
	_ "regexp"

	"golang.org/x/crypto/bcrypt"
	_ "golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
func (p *PasswordService) HashPassword(password string) (string, error) {
	// TODO: Implement password hashing
	// Use golang.org/x/crypto/bcrypt.GenerateFromPassword

	if password == "" {
		return "", errors.New("password must not be empty")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}

	return string(hash), nil
}

// VerifyPassword checks if password matches hash
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

// ValidatePassword checks if password meets basic requirements
func ValidatePassword(password string) error {
	// TODO: Implement password validation

	// At least 6 characters
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	// Contains at least one letter and one number
	letter := regexp.MustCompile(`[A-Za-z]`)
	digit := regexp.MustCompile(`[0-9]`)

	if !letter.MatchString(password) || !digit.MatchString(password) {
		return errors.New("password must contain at least one letter and one number")
	}

	return nil
}
