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

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cant be empty")
	}

	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}

	return string(bytes), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	return password != "" && hash != "" && bcrypt.CompareHashAndPassword([]byte(hash), []byte(password)) == nil
}

func hasLetter(s string) bool {
	for _, r := range s {
		if unicode.IsLetter(r) {
			return true
		}
	}
	return false
}

func hasNumber(s string) bool {
	for _, r := range s {
		if unicode.IsDigit(r) {
			return true
		}
	}
	return false
}

func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must be at least 6 character")
	}
	if !(hasLetter(password) && hasNumber(password)) {
		return errors.New("password must include at least one letter and one digit")
	}
	return nil
}