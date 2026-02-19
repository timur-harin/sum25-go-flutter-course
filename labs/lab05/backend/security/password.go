package security

import (
	"errors"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService creates a new password service
func NewPasswordService() *PasswordService {
	// Return a new PasswordService instance
	return &PasswordService{}
}

// HashPassword hashes a password using bcrypt
func (p *PasswordService) HashPassword(password string) (string, error) {
	// TODO: Implement password hashing
	// Use golang.org/x/crypto/bcrypt.GenerateFromPassword
	// Check the password
	if password == "" {
		return "", errors.New("empty password provided: HashPassword()")
	}

	// Get the password hash
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)

	// Return the password as a string
	return string(hash), err
}

// VerifyPassword checks if password matches hash
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	// Check if the password or hash is empty
	if password == "" || hash == "" {
		return false
	}

	// Compare the hash and the password
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// StrCount counts the number of "ch" in "src"
func StrCount(src string, ch rune) int {
	cnt := 0
	for _, cur := range src {
		if cur == ch {
			cnt++
		}
	}

	return cnt
}

// ValidatePassword checks if password meets basic requirements
func ValidatePassword(password string) error {
	// Check the length
	const minPasswordLength = 6
	if len(password) < minPasswordLength {
		return errors.New("password should be at least 6 characters in length")
	}

	// Check if the password contains at least one letter
	lettersStr := "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM"
	var containsLetter bool = false
	for _, ch := range lettersStr {
		if StrCount(password, ch) > 0 {
			containsLetter = true
		}
	}

	// Check if the password contains at least one letter
	digitsStr := "0123456789"
	var containsDigit bool = false
	for _, ch := range digitsStr {
		if StrCount(password, ch) > 0 {
			containsDigit = true
		}
	}

	if !containsLetter || !containsDigit {
		return errors.New("password must contain a letter and a digit")
	}

	// OK, valid password
	return nil
}
