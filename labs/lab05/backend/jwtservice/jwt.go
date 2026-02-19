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
		return nil, errors.New("secret key cannot be empty")
	}
	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken creates a new JWT token with user claims
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", errors.New("user ID must be positive")
	}
	if email == "" {
		return "", errors.New("email cannot be empty")
	}

	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(j.secretKey))
}

// ValidateToken parses and validates a JWT token
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if tokenString == "" {
		return nil, ErrEmptyToken
	}

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, NewInvalidSigningMethodError(token.Header["alg"])
		}
		return []byte(j.secretKey), nil
	})

	if err != nil {
		var jwtErr *jwt.ValidationError
		if errors.As(err, &jwtErr) {
			if jwtErr.Errors&jwt.ValidationErrorExpired != 0 {
				return nil, ErrTokenExpired
			}
		}
		return nil, ErrInvalidToken
	}

	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	return nil, ErrInvalidToken
}
