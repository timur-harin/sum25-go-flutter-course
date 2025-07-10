package security

import (
	"testing"
)

func TestNewPasswordService(t *testing.T) {
	service := NewPasswordService()
	if service == nil {
		t.Error("NewPasswordService should return a non-nil service")
	}
}

func TestPasswordService_HashPassword(t *testing.T) {
	service := NewPasswordService()

	tests := []struct {
		name     string
		password string
		wantErr  bool
	}{
		{"valid password", "password123", false},
		{"empty password", "", true},
		{"short password", "abc123", false},
		{"long password", "this-is-a-very-long-password-123", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hash, err := service.HashPassword(tt.password)
			if (err != nil) != tt.wantErr {
				t.Errorf("HashPassword() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !tt.wantErr && hash == "" {
				t.Error("HashPassword() should return non-empty hash for valid password")
			}
			if !tt.wantErr && hash == tt.password {
				t.Error("HashPassword() should not return the original password")
			}
		})
	}
}

func TestPasswordService_VerifyPassword(t *testing.T) {
	service := NewPasswordService()
	password := "testpassword123"

	// First hash the password
	hash, err := service.HashPassword(password)
	if err != nil {
		t.Fatalf("Failed to hash password: %v", err)
	}

	tests := []struct {
		name     string
		password string
		hash     string
		want     bool
	}{
		{"correct password", password, hash, true},
		{"wrong password", "wrongpassword", hash, false},
		{"empty password", "", hash, false},
		{"empty hash", password, "", false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := service.VerifyPassword(tt.password, tt.hash)
			if result != tt.want {
				t.Errorf("VerifyPassword() = %v, want %v", result, tt.want)
			}
		})
	}
}

func TestValidatePassword(t *testing.T) {
	tests := []struct {
		name     string
		password string
		wantErr  bool
	}{
		{"valid password", "abc123", false},
		{"valid complex password", "MyPassword123", false},
		{"too short", "ab1", true},
		{"no numbers", "abcdef", true},
		{"no letters", "123456", true},
		{"empty password", "", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidatePassword(tt.password)
			if (err != nil) != tt.wantErr {
				t.Errorf("ValidatePassword() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
