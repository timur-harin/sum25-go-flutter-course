package jwtservice

import (
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

type JWTService struct {
	secretKey []byte
	issuer    string
	expiry    time.Duration
}

func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, errors.New("secret cannot be empty")
	}
	return &JWTService{
		secretKey: []byte(secretKey),
		issuer:    "app-name",
		expiry:    24 * time.Hour,
	}, nil
}

func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", errors.New("userID must be positive")
	}
	if email == "" {
		return "", errors.New("email cannot be empty")
	}
	claims := &Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    j.issuer,
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(j.expiry)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(j.secretKey))
}

func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString,
		&Claims{},
		func(token *jwt.Token) (interface{}, error) {
			// verify the signing method is HMAC (HS256)
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}
			// return the secret key for signature verification
			return j.secretKey, nil
		})

	// handle parsing errors
	if err != nil {
		return nil, fmt.Errorf("token validation failed: %w", err)
	}

	// check if the token is valid and extract claims
	if claims, ok := token.Claims.(*Claims); ok && token.Valid {
		return claims, nil
	}

	// if claims are invalid or malformed
	return nil, errors.New("invalid token claims")
}
