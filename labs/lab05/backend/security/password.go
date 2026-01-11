package security

import (
	"errors"
	"golang.org/x/crypto/bcrypt"
	_ "regexp"

	_ "golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password is empty")
	}
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

// VerifyPassword checks if password matches hash
// Requirements:
// - password and hash must not be empty
// - return true if password matches hash
// - return false if password doesn't match
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	if err != nil {
		return false
	}
	return true
}

// ValidatePassword checks if password meets basic requirements
// Requirements:
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 8 characters")
	}
	letter := false
	number := false
	for _, ch := range password {
		if ch >= 65 && ch <= 90 {
			letter = true
		}
		if ch >= 97 && ch <= 122 {
			letter = true
		}
		if ch >= 48 && ch <= 57 {
			number = true
		}
	}
	if !letter || !number {
		return errors.New("password contain at least one uppercase, lowercase, and number")
	}
	return nil
}
