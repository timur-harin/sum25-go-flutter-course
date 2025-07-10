package jwtservice

import (
	"errors"
	_ "github.com/golang-jwt/jwt/v4"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// TODO: Implement NewJWTService function
// NewJWTService creates a new JWT service
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	// TODO: Implement this function
	// Validate secretKey and create service instance
	return nil, errors.New("not implemented")
}

// TODO: Implement GenerateToken method
// GenerateToken creates a new JWT token with user claims
// Requirements:
// - userID must be positive
// - email must not be empty
// - Token expires in 24 hours
// - Use HS256 signing method
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	// TODO: Implement token generation
	// Create claims with userID, email, and expiration
	// Sign token with secret key
	return "", errors.New("not implemented")
}

// TODO: Implement ValidateToken method
// ValidateToken parses and validates a JWT token
// Requirements:
// - Check token signature with secret key
// - Verify token is not expired
// - Return parsed claims on success
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	// TODO: Implement token validation
	// Parse token and verify signature
	// Return claims if valid
	return nil, errors.New("not implemented")
}
