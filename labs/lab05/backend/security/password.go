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
	// ???
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("Password is empty")
	}
	pswHashed, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(pswHashed), nil
}

// VerifyPassword checks if password matches hash
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
// - At least 6 characters
// - Contains at least one letter and one number
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("Password is too short")
	}
	//shitty checker
	//think it needed to be rewrited
	re1 := regexp.MustCompile(`[a-z]+[0-9]`)
	re2 := regexp.MustCompile(`[0-9]+[a-z]`)

	if !re1.MatchString(password) && !re2.MatchString(password) {
		return errors.New("password is too easy")
	}
	return nil
}
