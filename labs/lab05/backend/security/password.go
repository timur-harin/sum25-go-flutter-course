package security

import (
	"errors"
	"regexp"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt with a default cost.
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cannot be empty")
	}

	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	return string(hashedBytes), nil
}

// VerifyPassword checks if a given plaintext password matches a bcrypt hash.
// It returns true only if the password and hash are not empty and the password matches the hash.
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}

	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword checks if a password meets basic security requirements:
// - At least 6 characters long.
// - Contains at least one letter.
// - Contains at least one number.
// An alternative implementation without regexp is also provided for clarity.
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	hasLetter, _ := regexp.MatchString(`[a-zA-Z]`, password)
	hasNumber, _ := regexp.MatchString(`[0-9]`, password)

	if !hasLetter || !hasNumber {
		return errors.New("password must contain at least one letter and one number")
	}

	return nil
}

// ValidatePasswordWithoutRegexp is an alternative implementation using unicode package.
// This version can be more performant than regexp for simple checks.
func ValidatePasswordWithoutRegexp(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	var hasLetter, hasNumber bool
	for _, char := range password {
		switch {
		case unicode.IsLetter(char):
			hasLetter = true
		case unicode.IsNumber(char):
			hasNumber = true
		}
	}

	if !hasLetter || !hasNumber {
		return errors.New("password must contain at least one letter and one number")
	}

	return nil
}
