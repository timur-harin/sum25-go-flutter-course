package jwtservice

import (
	"github.com/golang-jwt/jwt/v4"
)

// Claims represents JWT token claims
type Claims struct {
	UserID int    `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

// Valid validates the claims (required by jwt.Claims interface)
func (c Claims) Valid() error {
	return c.RegisteredClaims.Valid()
}
