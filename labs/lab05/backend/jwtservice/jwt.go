package jwtservice

import (
	"fmt"
	"github.com/golang-jwt/jwt/v4"
	"time"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
	expiry    time.Duration
}

// TODO: Implement NewJWTService function
// NewJWTService creates a new JWT service
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	// TODO: Implement this function
	// Validate secretKey and create service instance
	if secretKey == "" {
		return nil, NewValidationError(secretKey, "secret key cannot be empty")
	}

	return &JWTService{secretKey: secretKey, expiry: 24 * time.Hour}, nil
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
	if userID <= 0 {
		return "", NewValidationError("userID", "user id must positive")
	}
	if email == "" {
		return "", NewValidationError("email", "email cannot be empty")
	}

	claims := jwt.MapClaims{
		"user_id": userID,
		"email":   email,
		"exp":     time.Now().Add(j.expiry).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	tokenString, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", fmt.Errorf("failed to sign token: %w", err)
	}

	return tokenString, nil
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
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, NewInvalidSigningMethodError("unexpected signing method")
		}
		return []byte(j.secretKey), nil
	})

	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, ErrInvalidClaims
	}

	expFloat, ok := claims["exp"].(float64)
	if !ok {
		return nil, NewValidationError("exp", "expiration claim is missing or not a valid number")
	}
	expirationTime := time.Unix(int64(expFloat), 0)

	if time.Now().After(expirationTime) {
		return nil, ErrTokenExpired
	}

	var userID int
	if userIDVal, ok := claims["user_id"]; ok {
		if uidFloat, isFloat := userIDVal.(float64); isFloat {
			userID = int(uidFloat)
		} else if uidInt, isInt := userIDVal.(int); isInt {
			userID = uidInt
		} else {
			return nil, NewValidationError("userID", "unexpected type for user_id claim")
		}
	} else {
		return nil, NewValidationError("userID", "user_id claim is missing")
	}

	var email string
	if emailVal, ok := claims["email"].(string); ok {
		email = emailVal
	} else {
		return nil, NewValidationError("email", "email claim is missing or not a string")
	}

	return &Claims{
		UserID: userID,
		Email:  email,
	}, nil
}
