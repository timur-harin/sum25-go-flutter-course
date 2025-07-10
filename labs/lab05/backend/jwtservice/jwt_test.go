package jwtservice

import (
	"testing"
)

func TestNewJWTService(t *testing.T) {
	tests := []struct {
		name      string
		secretKey string
		wantErr   bool
	}{
		{"valid secret", "my-secret-key", false},
		{"empty secret", "", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			service, err := NewJWTService(tt.secretKey)
			if (err != nil) != tt.wantErr {
				t.Errorf("NewJWTService() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && service == nil {
				t.Error("NewJWTService() should return non-nil service")
			}
		})
	}
}

func TestJWTService_GenerateToken(t *testing.T) {
	service, _ := NewJWTService("test-secret")

	tests := []struct {
		name    string
		userID  int
		email   string
		wantErr bool
	}{
		{"valid user", 1, "test@example.com", false},
		{"valid user 2", 123, "user@test.com", false},
		{"zero userID", 0, "test@example.com", true},
		{"negative userID", -1, "test@example.com", true},
		{"empty email", 1, "", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			token, err := service.GenerateToken(tt.userID, tt.email)
			if (err != nil) != tt.wantErr {
				t.Errorf("GenerateToken() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && token == "" {
				t.Error("GenerateToken() should return non-empty token")
			}
		})
	}
}

func TestJWTService_ValidateToken(t *testing.T) {
	service, _ := NewJWTService("test-secret")
	userID := 123
	email := "test@example.com"

	// Generate a valid token
	token, err := service.GenerateToken(userID, email)
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	tests := []struct {
		name    string
		token   string
		wantErr bool
	}{
		{"valid token", token, false},
		{"empty token", "", true},
		{"invalid token", "invalid.token.here", true},
		{"malformed token", "not-a-jwt-token", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			claims, err := service.ValidateToken(tt.token)
			if (err != nil) != tt.wantErr {
				t.Errorf("ValidateToken() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr {
				if claims == nil {
					t.Error("ValidateToken() should return non-nil claims")
				}
				if claims.UserID != userID {
					t.Errorf("ValidateToken() userID = %v, want %v", claims.UserID, userID)
				}
				if claims.Email != email {
					t.Errorf("ValidateToken() email = %v, want %v", claims.Email, email)
				}
			}
		})
	}
}

func TestJWTService_TokenExpiry(t *testing.T) {
	service, _ := NewJWTService("test-secret")
	userID := 123
	email := "test@example.com"

	// Generate a token
	token, err := service.GenerateToken(userID, email)
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	// Token should be valid immediately
	claims, err := service.ValidateToken(token)
	if err != nil {
		t.Errorf("Token should be valid immediately: %v", err)
	}
	if claims == nil {
		t.Error("Claims should not be nil for valid token")
	}

	// Note: In a real test, you might test expiry by mocking time
	// or creating tokens with very short expiry times
}

func TestJWTService_DifferentSecrets(t *testing.T) {
	service1, _ := NewJWTService("secret1")
	service2, _ := NewJWTService("secret2")

	userID := 123
	email := "test@example.com"

	// Generate token with service1
	token, err := service1.GenerateToken(userID, email)
	if err != nil {
		t.Fatalf("Failed to generate token: %v", err)
	}

	// Try to validate with service2 (different secret) - should fail
	_, err = service2.ValidateToken(token)
	if err == nil {
		t.Error("Token should not be valid with different secret")
	}

	// Validate with service1 (same secret) - should succeed
	claims, err := service1.ValidateToken(token)
	if err != nil {
		t.Errorf("Token should be valid with same secret: %v", err)
	}
	if claims == nil {
		t.Error("Claims should not be nil for valid token")
	}
}
