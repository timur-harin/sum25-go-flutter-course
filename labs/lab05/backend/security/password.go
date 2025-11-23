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

func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cannot be empty")
	}
	hashed, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hashed), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}
	hasLetter := regexp.MustCompile(`[A-Za-z]`).MatchString(password)
	hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
	if !hasLetter || !hasNumber {
		return errors.New("password must contain at least one letter and one number")
	}
	return nil
}
