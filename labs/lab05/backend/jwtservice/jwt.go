package jwtservice

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// NewJWTService creates a new JWT service instance if the secret key is not empty
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, errors.New("secret key must not be empty")
	}
	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken generates a JWT token with userID and email, valid for 24 hours
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", errors.New("userID must be positive")
	}
	if email == "" {
		return "", errors.New("email must not be empty")
	}

	// Set claims with userID, email, and expiration time
	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)), // expire in 24h
			IssuedAt:  jwt.NewNumericDate(time.Now()),                     // issued now
		},
	}

	// Create a new token with HS256 signing method
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Sign the token using the secret key
	signedToken, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", err
	}

	return signedToken, nil
}

// ValidateToken parses and validates a JWT token, returning claims if valid
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if tokenString == "" {
		return nil, errors.New("token must not be empty")
	}

	// Parse and validate the token
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// Check the signing method is HMAC
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(j.secretKey), nil
	})
	if err != nil {
		return nil, err
	}

	// Return claims if token is valid
	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, errors.New("invalid token")
}
