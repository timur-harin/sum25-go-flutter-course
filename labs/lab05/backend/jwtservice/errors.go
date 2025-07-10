package jwtservice

import "fmt"

// ErrInvalidToken indicates the token is invalid
var ErrInvalidToken = fmt.Errorf("invalid token")

// ErrTokenExpired indicates the token has expired
var ErrTokenExpired = fmt.Errorf("token expired")

// ErrInvalidClaims indicates the token claims are invalid
var ErrInvalidClaims = fmt.Errorf("invalid token claims")

// ErrEmptyToken indicates the token string is empty
var ErrEmptyToken = fmt.Errorf("token string cannot be empty")

// InvalidSigningMethodError represents an error for invalid signing method
type InvalidSigningMethodError struct {
	Method interface{}
}

func (e InvalidSigningMethodError) Error() string {
	return fmt.Sprintf("unexpected signing method: %v", e.Method)
}

// NewInvalidSigningMethodError creates a new InvalidSigningMethodError
func NewInvalidSigningMethodError(method interface{}) error {
	return InvalidSigningMethodError{Method: method}
}

// ValidationError represents a validation error
type ValidationError struct {
	Field   string
	Message string
}

func (e ValidationError) Error() string {
	return fmt.Sprintf("validation error for field '%s': %s", e.Field, e.Message)
}

// NewValidationError creates a new ValidationError
func NewValidationError(field, message string) error {
	return ValidationError{Field: field, Message: message}
}
