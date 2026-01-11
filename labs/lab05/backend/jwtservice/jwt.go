package jwtservice

import (
	"time"

	"github.com/golang-jwt/jwt/v4"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// NewJWTService creates a new JWT service
// Updated for GitHub Actions compatibility
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, NewValidationError("secretKey", "cannot be empty")
	}

	return &JWTService{
		secretKey: secretKey,
	}, nil
}

// GenerateToken creates a new JWT token with user claims
// Requirements:
// - userID must be positive
// - email must not be empty
// - Token expires in 24 hours
// - Use HS256 signing method
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", NewValidationError("userID", "must be positive")
	}

	if email == "" {
		return "", NewValidationError("email", "cannot be empty")
	}

	// Create claims with userID, email, and expiration
	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			NotBefore: jwt.NewNumericDate(time.Now()),
		},
	}

	// Create token with claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Sign token with secret key
	tokenString, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

// ValidateToken parses and validates a JWT token
// Requirements:
// - Check token signature with secret key
// - Verify token is not expired
// - Return parsed claims on success
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if tokenString == "" {
		return nil, ErrEmptyToken
	}

	// Parse token and verify signature
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// Check signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, NewInvalidSigningMethodError(token.Header["alg"])
		}
		return []byte(j.secretKey), nil
	})

	if err != nil {
		// Check for specific JWT errors
		if ve, ok := err.(*jwt.ValidationError); ok {
			if ve.Errors&jwt.ValidationErrorExpired != 0 {
				return nil, ErrTokenExpired
			}
			if ve.Errors&jwt.ValidationErrorSignatureInvalid != 0 {
				return nil, ErrInvalidToken
			}
		}
		return nil, ErrInvalidToken
	}

	// Extract claims
	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, ErrInvalidClaims
}
