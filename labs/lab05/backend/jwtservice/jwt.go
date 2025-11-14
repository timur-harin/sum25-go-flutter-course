package jwtservice

import (
	"errors"
	"github.com/golang-jwt/jwt/v4"
	"time"
)

// JWTService handles JWT token operations
type JWTService struct {
	secretKey string
}
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, ErrEmptySecretKey
	}

	newJWT := &JWTService{secretKey: secretKey}
	return newJWT, nil
}

func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", ErrNonPosUserID
	}
	if email == "" {
		return "", ErrEmptyEmail
	}

	claims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour * 24)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	generatedToken := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return generatedToken.SignedString([]byte(j.secretKey))
}

func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, ErrUnexpSignMethod
			}
			return []byte(j.secretKey), nil
		})

	if err != nil || !token.Valid {
		return nil, ErrInvToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return nil, ErrInvClaims
	}

	return &Claims{
		UserID: int(claims["user_id"].(float64)),
		Email:  claims["email"].(string),
	}, nil
}

var (
	ErrEmptySecretKey  = errors.New("secret cannot be empty")
	ErrNonPosUserID    = errors.New("user ID must be positive")
	ErrEmptyEmail      = errors.New("email cannot be empty")
	ErrUnexpSignMethod = errors.New("unexpected signing method")
	ErrInvToken        = errors.New("invalid token")
	ErrInvClaims       = errors.New("invalid claims")
)