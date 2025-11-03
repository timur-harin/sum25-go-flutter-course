package security

import (
	"errors"
	"unicode"

	"golang.org/x/crypto/bcrypt"
)

var (
	ErrEmptyPassword   = errors.New("password cannot be empty")
	ErrEmptyHash       = errors.New("hash cannot be empty")
	ErrHashingPassword = errors.New("error hashing password")
	
	ErrShortPassword = errors.New("password too short")
	ErrNoPasswordDigit = errors.New("password must contain a digit")
	ErrNoPasswordLetter = errors.New("password must contain a letter")
	ErrNoPasswordUpper = errors.New("password must contain an uppercase letter")
	ErrNoPasswordLower = errors.New("password must contain a lowercase letter")
)

// PasswordService handles password operations
type PasswordService struct{}

func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", ErrEmptyPassword
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", ErrHashingPassword
	}
	return string(hash), nil
}

func (p *PasswordService) VerifyPassword(password, hash string) bool {
	res := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return res == nil
}

func ValidatePassword(password string) error {
    if len(password) < 6 {
        return ErrShortPassword
    }

    hasLetter := false
    hasDigit  := false
	
    for _, c := range password {
        if unicode.IsLetter(c) {
            hasLetter = true
        } else if unicode.IsDigit(c) {
            hasDigit = true
        }
    }

    if !hasLetter { return ErrNoPasswordLetter }
	if !hasDigit { return ErrNoPasswordDigit }
	return nil
}
