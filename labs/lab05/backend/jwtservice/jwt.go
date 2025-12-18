package jwtservice

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

// Claims represents the JWT claims
// Embeds jwt.RegisteredClaims for standard fields
// and adds custom fields for UserID and Email
type JWTClaims struct {
	UserID int    `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// NewJWTService creates a new JWT service
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, errors.New("secret key must not be empty")
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
		return "", errors.New("userID must be positive")
	}
	if email == "" {
		return "", errors.New("email must not be empty")
	}

	now := time.Now()
	expiresAt := now.Add(24 * time.Hour)

	claims := &JWTClaims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expiresAt),
			IssuedAt:  jwt.NewNumericDate(now),
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
// Requirements:
// - Check token signature with secret key
// - Verify token is not expired
// - Return parsed claims on success
func (j *JWTService) ValidateToken(tokenString string) (*JWTClaims, error) {
	if tokenString == "" {
		return nil, errors.New("token string must not be empty")
	}

	parsedToken, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Ensure token method is HS256
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(j.secretKey), nil
	})
	if err != nil {
		return nil, err
	}

	claims, ok := parsedToken.Claims.(*JWTClaims)
	if !ok || !parsedToken.Valid {
		return nil, errors.New("invalid token")
	}

	// Token is valid and claims contain our data
	return claims, nil
}
