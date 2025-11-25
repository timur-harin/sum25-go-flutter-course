package security

import (
	"errors"
	"unicode"

	"golang.org/x/crypto/bcrypt"

	_ "golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService implementation
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword function implementation
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("password can not be nil")
	}

	// Hashed password generation with bcrypt
	// bcrypt the most useful staff for passwords hashing
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), 10)

	if err != nil {
		return "", errors.New("password hashing was failed")
	}

	return string(hashedPassword), nil
}

// VerifyPassword method implementation
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" {
		return false
	}

	if hash == "" {
		return false
	}

	// Password and stored hash comparison
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("password must contains at least 6 symbols")
	}

	var hasLetter, hasDigit bool
	for _, char := range password {
		switch {
		// to simplify the letter and number checker let's use unicode
		case unicode.IsLetter(char):
			hasLetter = true

		case unicode.IsDigit(char):
			hasDigit = true
		}

		if hasLetter && hasDigit {
			return nil
		}
	}
	return errors.New("password must contins at least one letter and one digit")
}
