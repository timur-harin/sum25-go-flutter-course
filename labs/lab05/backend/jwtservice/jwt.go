package jwtservice

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt" // automatic fix, previous did not work
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

// NewJWTService creates a new JWT service
// Requirements:
// - secretKey must not be empty
func NewJWTService(secretKey string) (*JWTService, error) {
	// Check the secret key
	if len(secretKey) == 0 {
		return nil, errors.New("empty secret key provided")
	}

	// OK -> create a new JWTService
	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken creates a new JWT token with user claims
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	// Check the user ID
	if userID <= 0 {
		return "", errors.New("invalid user ID: GenerateToken()")
	}

	// Check the email
	if len(email) == 0 {
		return "", errors.New("empty email: GenerateToken()")
	}

	// Create claims for the token
	dayDuration := time.Duration.Hours(24)

	claims := jwt.MapClaims{
		"user_id": userID,
		"email":   email,
		// expires in 24 hours from "Now()"
		"exp": time.Now().Add(time.Duration(dayDuration)).Unix(),
	}

	// Create a token with the HS256 signing method and the needed claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)

	// Sign the token
	return token.SignedString([]byte(j.secretKey))
}

// ValidateToken parses and validates a JWT token
func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	// Parse the token
	token, err := jwt.Parse(tokenString,
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, NewInvalidSigningMethodError(token.Method)
			}
			return []byte(j.secretKey), nil
		})

	// Check for parsing errors
	if err != nil || !token.Valid {
		return nil, ErrInvalidToken
	}

	// Get the claims
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, ErrInvalidClaims
	}

	return &Claims{
		UserID: int(claims["user_id"].(float64)),
		Email:  claims["email"].(string),
	}, nil // OK, no error
}
