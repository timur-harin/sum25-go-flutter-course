package security

import (
	"errors"
	_ "regexp"
	"strings"
	"unicode"

	"golang.org/x/crypto/bcrypt"
	_ "golang.org/x/crypto/bcrypt"
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
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	return string(bytes), err
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func HasLetter(s string) bool { // checks that the string contains at least one letter
	for _, r := range s {
		if unicode.IsLetter(r) {
			return true
		}
	}
	return false
}

func HasNumber(s string) bool { // checks that the string contains at least one number
	for _, r := range s {
		if unicode.IsNumber(r) {
			return true
		}
	}
	return false
}

func ValidatePassword(password string) error {
	// TODO: Implement password validation
	// Check length and basic complexity requirements
	trimmed := strings.TrimSpace(password)
	if len(trimmed) < 6 {
		return errors.New("password has to contain at least 6 characters")
	}
	if !HasNumber(password) || !HasLetter(password) {
		return errors.New("password has to contain at least one letter and one number")
	}
	return nil
}
