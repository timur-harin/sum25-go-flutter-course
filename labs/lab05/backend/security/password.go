package security

import (
	"errors"
	_ "regexp"

	"golang.org/x/crypto/bcrypt"
	_ "golang.org/x/crypto/bcrypt"
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
		return "", errors.New("password must not be empty")
	}
	
	hashedBytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hashedBytes), nil
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
	if len(password) < 6 {
		return errors.New("password must be at least 6 characters")
	}

	hasLetter := false
	hasNumber := false
	for _, c := range password {
		switch {
		case 'a' <= c && c <= 'z':
			hasLetter = true
		case 'A' <= c && c <= 'Z':
			hasLetter = true
		case '0' <= c && c <= '9':
			hasNumber = true
		}
	}

	if !hasLetter || !hasNumber {
		return errors.New("password must contain at least one letter and one number")
	}

	return nil
}
