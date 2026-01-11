package jwtservice

import (
	_ "errors"
	"fmt"

	"github.com/golang-jwt/jwt/v4"
	_ "github.com/golang-jwt/jwt/v4"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// NewJWTService creates a new JWT service
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, fmt.Errorf("ERROR")
	}

	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken creates a new JWT token with user claims
// Requirements:
// - userID must be positive
// - email must not be empty
// - Token expires in 24 hours
// - Use HS256 signing method
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", fmt.Errorf("userID must be positive")
	}

	if email == "" {
		return "", fmt.Errorf("email must not be empty")
	}

	claims := Claims{
		UserID: userID,
		Email:  email,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	return token.SignedString([]byte(j.secretKey))
}

// ValidateToken parses and validates a JWT token
// Requirements:
// - Check token signature with secret key
// - Verify token is not expired
// - Return parsed claims on success
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	claims := &Claims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		return []byte(j.secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	fmt.Println("TROK:", claims)
	if !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}
