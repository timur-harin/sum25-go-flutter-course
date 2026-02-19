package security

import (
	"errors"
	"regexp"

	"golang.org/x/crypto/bcrypt"
)

// PasswordService handles password operations
type PasswordService struct{}

// NewPasswordService создает новый экземпляр PasswordService
func NewPasswordService() *PasswordService {
	return &PasswordService{}
}

// HashPassword хеширует пароль с помощью bcrypt
// Требования:
// - пароль не должен быть пустым
// - использовать bcrypt с cost 10
// - возвращать хешированный пароль как строку
func (p *PasswordService) HashPassword(password string) (string, error) {
	if password == "" {
		return "", errors.New("пароль не должен быть пустым")
	}
	hash, err := bcrypt.GenerateFromPassword([]byte(password), 10)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

// VerifyPassword проверяет, совпадает ли пароль с хешем
// Требования:
// - пароль и хеш не должны быть пустыми
// - возвращает true, если пароль совпадает с хешем
// - возвращает false, если пароль не совпадает
func (p *PasswordService) VerifyPassword(password, hash string) bool {
	if password == "" || hash == "" {
		return false
	}
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}

// ValidatePassword проверяет, соответствует ли пароль базовым требованиям
// Требования:
// - не менее 6 символов
// - содержит хотя бы одну букву и одну цифру
func ValidatePassword(password string) error {
	if len(password) < 6 {
		return errors.New("пароль должен содержать не менее 6 символов")
	}
	letterRegexp := regexp.MustCompile(`[A-Za-z]`)
	numberRegexp := regexp.MustCompile(`[0-9]`)
	if !letterRegexp.MatchString(password) {
		return errors.New("пароль должен содержать хотя бы одну букву")
	}
	if !numberRegexp.MatchString(password) {
		return errors.New("пароль должен содержать хотя бы одну цифру")
	}
	return nil
}
