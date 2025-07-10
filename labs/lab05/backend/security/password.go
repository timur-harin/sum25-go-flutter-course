package security

import (
	"errors"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

type PasswordService struct{}

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password cannot be empty")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hash), nil
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
		return errors.New("password must be at least 6 characters")
	}

	hasLetter := false
	hasDigit := false

	for _, c := range password {
		if unicode.IsLetter(c) {
			hasLetter = true
		} else if unicode.IsDigit(c) {
			hasDigit = true
		}
	}

	if !hasLetter || !hasDigit {
		return errors.New("password must contain at least one letter and one number")
	}
	return nil
}