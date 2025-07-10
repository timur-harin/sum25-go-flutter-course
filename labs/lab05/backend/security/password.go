package security

import (
	"errors"
	_ "regexp"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

func (p *PasswordService) HashPassword(password string) (string, error) {
	if err := ValidatePassword(password); err != nil {
		return "", err
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hash[:]), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if err := ValidatePassword(password); err != nil {
		return false
	}
	if err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)); err != nil {
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
	// TODO: Implement password validation
	// Check length and basic complexity requirements
	if len(password) < 6 {
		return errors.New("invalid password")
	}
	var hasLetter, hasDigit bool

	for _, ch := range password {
		switch {
		case 'a' <= ch && ch <= 'z':
			hasLetter = true
		case 'A' <= ch && ch <= 'Z':
			hasLetter = true
		case '0' <= ch && ch <= '9':
			hasDigit = true
		}
	}

	if !hasLetter || !hasDigit {
		return errors.New("password must contain at least one lowercase letter, one uppercase letter, and one digit")
	}

	return nil
}
