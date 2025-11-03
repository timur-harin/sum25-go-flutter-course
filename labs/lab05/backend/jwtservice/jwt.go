
package jwtservice

import (
	"errors"
	"time"

	"github.com/go-playground/validator/v10"
	"github.com/golang-jwt/jwt/v4"
)

var (
	ErrEmptySecretKey     = errors.New("secret key cannot be empty")
	ErrInvalidID          = errors.New("id must be > 0")
	ErrInvalidEmail       = errors.New("email has invalid format")
	ErrSigningToken       = errors.New("error signing jwt token")
	ErrInvalidTokenMethod = errors.New("invalid token method")
	ErrInvalidClaims      = errors.New("invalid token claims")
	validate              = validator.New()
)


// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}

func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, ErrEmptySecretKey
	}
	return &JWTService{secretKey: secretKey}, nil
}

func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", ErrInvalidID
	}
	if err := validate.Var(email, "required,email"); err != nil {
		return "", ErrInvalidEmail
	}
	token := jwt.NewWithClaims(
		jwt.SigningMethodHS256,
		Claims{
			UserID: userID,
			Email:  email,
			RegisteredClaims: jwt.RegisteredClaims{
				ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			},
		},
	)
	signed, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", ErrSigningToken
	}
	return signed, nil
}

func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(
		tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, ErrInvalidTokenMethod
			}
			return []byte(j.secretKey), nil
		},
		jwt.WithValidMethods([]string{"HS256"}),
	)
	if err != nil {
		return nil, err
	}
	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, ErrInvalidClaims
	}
	return claims, nil
}
