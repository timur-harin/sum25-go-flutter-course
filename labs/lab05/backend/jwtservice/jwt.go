package jwtservice

import (
	"errors"
	"github.com/golang-jwt/jwt/v4"
	_ "github.com/golang-jwt/jwt/v4"
	"time"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, errors.New("secret key must not be empty")
	}
	return &JWTService{secretKey: secretKey}, nil
}

func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	// TODO: Implement token generation
	// Create claims with userID, email, and expiration
	// Sign token with secret key
	if userID <= 0 {
		return "", NewValidationError("user_id", "must be a positive integer")
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
		var verr *jwt.ValidationError
		if errors.As(err, &verr) {
			if verr.Errors&jwt.ValidationErrorExpired != 0 {
				return nil, ErrTokenExpired
			}
			return nil, ErrInvalidToken
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidClaims
	}

	return claims, nil
}
