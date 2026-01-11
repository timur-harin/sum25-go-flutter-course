package security

import (
	"errors"
	_ "regexp"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

func NewPasswordService() *PasswordService {
	// TODO: Implement this function
	// Return a new PasswordService instance
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
	return string(hash), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	// TODO: Implement password verification
	// Use bcrypt.CompareHashAndPassword
	// Return true only if passwords match exactly
	return bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}

func ValidatePassword(password string) error {
	// TODO: Implement password validation
	// Check length and basic complexity requirements
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters long")
	}
	hasLetter := false
	hasNumber := false
	for _, r := range password {
		if isLetter(r) {
			hasLetter = true
		}
		if isNumber(r) {
			hasNumber = true
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

func isLetter(r rune) bool {
	return (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z')
}
func isNumber(r rune) bool {
	return r >= '0' && r <= '9'
}
