package jwtservice

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

// CustomClaims определяет пользовательские данные для токена
type CustomClaims struct {
	UserID int    `json:"user_id"`
	Email  string `json:"email"`
	jwt.RegisteredClaims
}

// JWTService обрабатывает операции с JWT токенами
type JWTService struct {
	secretKey string
}

// NewJWTService создает новый сервис JWT
// Требования:
// - secretKey не должен быть пустым
func NewJWTService(secretKey string) (*JWTService, error) {
	if secretKey == "" {
		return nil, errors.New("secretKey не должен быть пустым")
	}
	return &JWTService{secretKey: secretKey}, nil
}

// GenerateToken создает новый JWT токен с пользовательскими claims
// Требования:
// - userID должен быть положительным
// - email не должен быть пустым
// - Токен истекает через 24 часа
// - Использовать метод подписи HS256
func (j *JWTService) GenerateToken(userID int, email string) (string, error) {
	if userID <= 0 {
		return "", errors.New("userID должен быть положительным")
	}
	if email == "" {
		return "", errors.New("email не должен быть пустым")
	}

	expirationTime := time.Now().Add(24 * time.Hour)
	claims := &CustomClaims{
		UserID: userID,
		Email:  email,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(expirationTime),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(j.secretKey))
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

// ValidateToken парсит и валидирует JWT токен
// Требования:
// - Проверить подпись токена с помощью secret key
// - Проверить, что токен не истек
// - Вернуть claims при успехе
func (j *JWTService) ValidateToken(tokenString string) (*CustomClaims, error) {
	claims := &CustomClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		// Проверяем, что используется метод подписи HS256
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("неверный метод подписи")
		}
		return []byte(j.secretKey), nil
	})

	if err != nil {
		return nil, err
	}

	if !token.Valid {
		return nil, errors.New("недействительный токен")
	}

	// Проверяем, что токен не истек
	if claims.ExpiresAt == nil || claims.ExpiresAt.Time.Before(time.Now()) {
		return nil, errors.New("токен истек")
	}

	return claims, nil
}
