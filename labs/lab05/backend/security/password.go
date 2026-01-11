package security

import (
	"errors"
	_ "regexp"
	"unicode"

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
	if password == "" {
		return "", errors.New("password cannot be empty")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 10)

	if err != nil {
		return "", err
	}

	return string(hashedPassword), nil
}

// VerifyPassword checks if password matches hash
func (p *PasswordService) VerifyPassword(password, hash string) bool {
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
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}

	var (
		hasLetter bool
		hasNumber bool
	)

	for _, char := range password {
		switch {
		case unicode.IsLetter(char):
			hasLetter = true
		case unicode.IsNumber(char):
			hasNumber = true
		}

		if hasLetter && hasNumber {
			break
		}
	}

	if !hasLetter {
		return errors.New("password must contain at least one letter")
	}

	if !hasNumber {
		return errors.New("password must contain at least one number")
	}

	return nil
}
