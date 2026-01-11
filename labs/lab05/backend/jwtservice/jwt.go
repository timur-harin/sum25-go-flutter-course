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
		return nil, errors.New("secretKey is required")
	}
	return &JWTService{secretKey: secretKey}, nil
}


func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	// Validate user ID
	if userID <= 0 {
		return "", errors.New("invalid userID")
	}
	
	// Validate email parameter
	if email == "" {
		return "", errors.New("email is required")
	}
	
	// Create token claims with user information
	tokenClaims := Claims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	
	// Create new token with claims
	newToken := jwt.NewWithClaims(jwt.SigningMethodHS256, tokenClaims)
	
	// Sign token with secret key
	signedToken, signingError := newToken.SignedString([]byte(j.secretKey))
	if signingError != nil {
		return "", signingError
	}
	
	return signedToken, nil
}


func (j *JWTService) ValidateToken(tokenString string) (*Claims, error) {
	// Check for empty token string
	if tokenString == "" {
		return nil, errors.New("token is required")
	}
	
	// Parse token with claims
	parsedToken, parseError := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
		// Verify signing method is HMAC
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(j.secretKey), nil
	})
	
	if parseError != nil {
		return nil, parseError
	}
	
	// Extract claims from token
	extractedClaims, claimsOk := parsedToken.Claims.(*Claims)
	if !claimsOk || !parsedToken.Valid {
		return nil, errors.New("invalid token")
	}
	
	// Check token expiration
	if extractedClaims.ExpiresAt == nil || extractedClaims.ExpiresAt.Time.Before(time.Now()) {
		return nil, errors.New("token expired")
	}
	
	return extractedClaims, nil
}