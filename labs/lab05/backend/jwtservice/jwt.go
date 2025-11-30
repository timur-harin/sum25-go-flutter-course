package jwtservice

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type JWTService struct {
	secretKey string
}

func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, NewValidationError("secretKey", "must not be empty")
	}
	return &JWTService{secretKey: secretKey}, nil
}

func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", NewValidationError("userID", "must be positive")
	}
	if email == "" {
		return "", NewValidationError("email", "must not be empty")
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
	return token.SignedString([]byte(j.secretKey))
}

func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if tokenString == "" {
		return nil, ErrEmptyToken
	}

	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, NewInvalidSigningMethodError(token.Method.Alg())
		}
		return []byte(j.secretKey), nil
	})
	if err != nil {
		var ve *jwt.ValidationError
		if errors.As(err, &ve) && ve.Errors&jwt.ValidationErrorExpired != 0 {
			return nil, ErrTokenExpired
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*Claims)
	if !ok {
		return nil, ErrInvalidClaims
	}
	if !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}
