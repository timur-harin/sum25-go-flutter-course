package userdomain

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNewUser(t *testing.T) {
	tests := []struct {
		name      string
		email     string
		userName  string
		password  string
		wantError bool
	}{
		{
			name:      "valid user creation",
			email:     "test@example.com",
			userName:  "John Doe",
			password:  "Password123",
			wantError: false,
		},
		{
			name:      "invalid email",
			email:     "invalid-email",
			userName:  "John Doe",
			password:  "Password123",
			wantError: true,
		},
		{
			name:      "name too short",
			email:     "test@example.com",
			userName:  "J",
			password:  "Password123",
			wantError: true,
		},

		{
			name:      "password too short",
			email:     "test@example.com",
			userName:  "John Doe",
			password:  "short",
			wantError: true,
		},
		{
			name:      "password without uppercase",
			email:     "test@example.com",
			userName:  "John Doe",
			password:  "password123",
			wantError: true,
		},
		{
			name:      "password without lowercase",
			email:     "test@example.com",
			userName:  "John Doe",
			password:  "PASSWORD123",
			wantError: true,
		},
		{
			name:      "password without number",
			email:     "test@example.com",
			userName:  "John Doe",
			password:  "Password",
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			user, err := NewUser(tt.email, tt.userName, tt.password)

			if tt.wantError {
				assert.Error(t, err)
				assert.Nil(t, user)
			} else {
				assert.NoError(t, err)
				require.NotNil(t, user)
				assert.Equal(t, tt.email, user.Email)
				assert.Equal(t, tt.userName, user.Name)
				assert.Equal(t, tt.password, user.Password)
				assert.False(t, user.CreatedAt.IsZero())
				assert.False(t, user.UpdatedAt.IsZero())
			}
		})
	}
}

func TestValidateEmail(t *testing.T) {
	tests := []struct {
		name      string
		email     string
		wantError bool
	}{
		{"valid email", "test@example.com", false},
		{"valid email with subdomain", "user@mail.example.com", false},
		{"valid email with numbers", "user123@example.com", false},
		{"empty email", "", true},
		{"email without @", "testexample.com", true},
		{"email without domain", "test@", true},
		{"email without local part", "@example.com", true},
		{"email with spaces", "test @example.com", true},
		{"email with multiple @", "test@@example.com", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidateEmail(tt.email)
			if tt.wantError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestValidateName(t *testing.T) {
	tests := []struct {
		name      string
		userName  string
		wantError bool
	}{
		{"valid name", "John Doe", false},
		{"minimum length name", "Jo", false},
		{"maximum length name", "John" + string(make([]byte, 46)), false}, // 50 chars total
		{"name with spaces", "  John Doe  ", false},                       // Should be trimmed
		{"empty name", "", true},
		{"name too short", "J", true},
		{"name too long", string(make([]byte, 51)), true},
		{"only spaces", "   ", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidateName(tt.userName)
			if tt.wantError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestValidatePassword(t *testing.T) {
	tests := []struct {
		name      string
		password  string
		wantError bool
	}{
		{"valid password", "Password123", false},
		{"valid complex password", "MyP@ssw0rd!", false},
		{"minimum valid password", "Abcdef12", false},
		{"empty password", "", true},
		{"password too short", "Pass1", true},
		{"password without uppercase", "password123", true},
		{"password without lowercase", "PASSWORD123", true},
		{"password without number", "Password", true},
		{"only uppercase", "ABCDEFGH", true},
		{"only lowercase", "abcdefgh", true},
		{"only numbers", "12345678", true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := ValidatePassword(tt.password)
			if tt.wantError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestUser_Validate(t *testing.T) {
	tests := []struct {
		name      string
		user      *User
		wantError bool
	}{
		{
			name: "valid user",
			user: &User{
				Email:    "test@example.com",
				Name:     "John Doe",
				Password: "Password123",
			},
			wantError: false,
		},
		{
			name: "invalid email",
			user: &User{
				Email:    "invalid-email",
				Name:     "John Doe",
				Password: "Password123",
			},
			wantError: true,
		},
		{
			name: "invalid name",
			user: &User{
				Email:    "test@example.com",
				Name:     "J",
				Password: "Password123",
			},
			wantError: true,
		},
		{
			name: "invalid password",
			user: &User{
				Email:    "test@example.com",
				Name:     "John Doe",
				Password: "weak",
			},
			wantError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.user.Validate()
			if tt.wantError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}

func TestUser_UpdateName(t *testing.T) {
	user := &User{
		Email:     "test@example.com",
		Name:      "John Doe",
		Password:  "Password123",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Test valid name update
	newName := "Jane Smith"
	err := user.UpdateName(newName)
	assert.NoError(t, err)
	assert.Equal(t, newName, user.Name)

	// Test invalid name update
	err = user.UpdateName("J")
	assert.Error(t, err)
	assert.Equal(t, newName, user.Name) // Should remain unchanged

	// Test name trimming
	err = user.UpdateName("  Bob Johnson  ")
	assert.NoError(t, err)
	assert.Equal(t, "Bob Johnson", user.Name)
}

func TestUser_UpdateEmail(t *testing.T) {
	user := &User{
		Email:     "test@example.com",
		Name:      "John Doe",
		Password:  "Password123",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Test valid email update
	newEmail := "newemail@example.com"
	err := user.UpdateEmail(newEmail)
	assert.NoError(t, err)
	assert.Equal(t, newEmail, user.Email)

	// Test invalid email update
	err = user.UpdateEmail("invalid-email")
	assert.Error(t, err)
	assert.Equal(t, newEmail, user.Email) // Should remain unchanged

	// Test email normalization (lowercase, trimmed)
	err = user.UpdateEmail("  TEST@EXAMPLE.COM  ")
	assert.NoError(t, err)
	assert.Equal(t, "test@example.com", user.Email)
}
