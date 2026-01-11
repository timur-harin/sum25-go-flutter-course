package security

import (
	"errors"
	"regexp"

	"golang.org/x/crypto/bcrypt"
)


type PasswordService struct{}

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

func (p *PasswordService) HashPassword(password string) (string, error) {
	// Check for empty password
	if password == "" {
		return "", errors.New("password is required")
	}
	
	// Generate bcrypt hash with cost 10
	hashedPassword, hashError := bcrypt.GenerateFromPassword([]byte(password), 10)
	if hashError != nil {
		return "", hashError
	}
	
	// Return hash as string
	return string(hashedPassword), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	// Check for empty inputs
	if password == "" || hash == "" {
		return false
	}
	
	// Compare password with hash
	comparisonError := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	
	// Return true if no error (passwords match)
	return comparisonError == nil
}

func ValidatePassword(password string) error {
	// Check minimum length requirement
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters")
	}
	
	// Define validation patterns
	letterPattern := regexp.MustCompile(`[A-Za-z]`)
	numberPattern := regexp.MustCompile(`[0-9]`)
	
	// Check for letter requirement
	if !letterPattern.MatchString(password) {
		return errors.New("password must contain at least one letter")
	}
	
	// Check for number requirement
	if !numberPattern.MatchString(password) {
		return errors.New("password must contain at least one number")
	}
	
	return nil
}