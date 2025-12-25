package security

import (
	"errors"
	_ "regexp"

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
		return "", errors.New("password is empty")
	}
	bytes, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	return string(bytes), err
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func ValidatePassword(password string) error {
	letters := []rune{}

	for symbol := 'a'; symbol <= 'z'; symbol++ {
		letters = append(letters, symbol)
	}

	for symbol := 'A'; symbol <= 'Z'; symbol++ {
		letters = append(letters, symbol)
	}

	if len(password) < 6 {
		return errors.New("invalid password")
	}

	hasLetter := false

	for i := 0; i < len(password); i++ {
		for j := 0; j < len(letters); j++ {
			if byte(password[i]) == byte(letters[j]) {
				hasLetter = true
				break
			}
		}
		if hasLetter {
			break
		}
	}

	if !hasLetter {
		return errors.New("invalid password")
	}

	digits := []int{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

	hasDigit := false

	for i := 0; i < len(password); i++ {
		for j := 0; j < len(digits); j++ {
			if byte(password[i]) == byte(digits[j]) {
				hasDigit = true
				break
			}
		}
		if hasDigit {
			break
		}
	}

	if !hasDigit {
		return errors.New("invalid password")
	}

	return nil
}
