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

// NewJWTService creates a new JWT service
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, ErrEmptyToken
	}
	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken creates a new JWT token with user claims
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", NewValidationError("userID", "must be positive")
	}
	if email == "" {
		return "", NewValidationError("email", "cannot be empty")
	}

	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	signedToken, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", err
	}

	return signedToken, nil
}
// ValidateToken parses and validates a JWT token
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if tokenString == "" {
		return nil, ErrEmptyToken
	}

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// Check signing method
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, NewInvalidSigningMethodError(token.Method.Alg())
		}
		return []byte(j.secretKey), nil
	})

	if err != nil {
		// Token might be expired or malformed
		var verr *jwt.ValidationError
		if errors.As(err, &verr) {
			if verr.Errors&jwt.ValidationErrorExpired != 0 {
				return nil, ErrTokenExpired
			}
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidClaims
	}

	return claims, nil
}
