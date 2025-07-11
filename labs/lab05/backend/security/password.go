package security

import (
	"errors"
	_"regexp"
	"strings"
	"golang.org/x/crypto/bcrypt"
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

	hashedPw, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", nil
	}
	return string(hashedPw), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	compareResult := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return compareResult == nil
}

func ValidatePassword(password string) error {
	if len(password) < 6 {
		return ErrInvPw
	}
	if !strings.ContainsAny(password, letters) || !strings.ContainsAny(password, numbers) {
		return ErrInvPw
	}
	return nil
}

var (
	ErrInvPw = errors.New("password must be at least 6 charecters long and contain at least one letter and one number")
)

var (
	letters = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm"
	numbers = "1234567890"
)