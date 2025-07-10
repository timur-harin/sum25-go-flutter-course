package jwtservice

import (
	"errors"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v4"
)


type JWTService struct {
	secretKey string
}


func NewJWTService(secretKey string) (*JWTService, error) {
	if strings.TrimSpace(secretKey) == "" {
		return nil, NewValidationError("secretKey", "secret key cannot be empty")
	}
	return &JWTService{secretKey: secretKey}, nil
}


func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", NewValidationError("userID", "userID must be positive")
	}
	if strings.TrimSpace(email) == "" {
		return "", NewValidationError("email", "email cannot be empty")
	}

	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(j.secretKey))
}


func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	if strings.TrimSpace(tokenString) == "" {
		return nil, ErrEmptyToken
	}

	claims := &Claims{}
	parsedToken, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok || t.Method.Alg() != jwt.SigningMethodHS256.Alg() {
			return nil, NewInvalidSigningMethodError(t.Header["alg"])
		}
		return []byte(j.secretKey), nil
	})
	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) || strings.Contains(err.Error(), "expired") {
			return nil, ErrTokenExpired
		}
		return nil, ErrInvalidToken
	}

	if !parsedToken.Valid {
		return nil, ErrInvalidToken
	}

	
	if claims.UserID <= 0 || claims.Email == "" {
		return nil, ErrInvalidClaims
	}

	return claims, nil
}