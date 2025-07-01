package user

import (
	"testing"
)

func TestNewUser(t *testing.T) {
	tests := []struct {
		name        string
		userName    string
		age         int
		email       string
		expectError bool
		errorType   error
	}{
		{
			name:        "valid user",
			userName:    "John Doe",
			age:         30,
			email:       "john@example.com",
			expectError: false,
		},
		{
			name:        "empty name",
			userName:    "",
			age:         30,
			email:       "john@example.com",
			expectError: true,
			errorType:   ErrInvalidName,
		},
		{
			name:        "invalid age - too young",
			userName:    "John Doe",
			age:         -1,
			email:       "john@example.com",
			expectError: true,
			errorType:   ErrInvalidAge,
		},
		{
			name:        "invalid age - too old",
			userName:    "John Doe",
			age:         151,
			email:       "john@example.com",
			expectError: true,
			errorType:   ErrInvalidAge,
		},
		{
			name:        "invalid email",
			userName:    "John Doe",
			age:         30,
			email:       "invalid-email@",
			expectError: true,
			errorType:   ErrInvalidEmail,
		},
		{
			name:        "not valid email",
			userName:    "John Doe",
			age:         30,
			email:       "john@notvalid",
			expectError: true,
			errorType:   ErrInvalidEmail,
		},
		{
			name:        "not valid email - no @",
			userName:    "John Doe",
			age:         30,
			email:       "johnnotvalid",
			expectError: true,
			errorType:   ErrInvalidEmail,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			user, err := NewUser(tt.userName, tt.age, tt.email)

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != tt.errorType {
					t.Errorf("Expected error %v, got %v", tt.errorType, err)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
				return
			}

			if user.Name != tt.userName {
				t.Errorf("Expected name %s, got %s", tt.userName, user.Name)
			}
			if user.Age != tt.age {
				t.Errorf("Expected age %d, got %d", tt.age, user.Age)
			}
			if user.Email != tt.email {
				t.Errorf("Expected email %s, got %s", tt.email, user.Email)
			}
		})
	}
}

func TestUserValidate(t *testing.T) {
	tests := []struct {
		name        string
		user        User
		expectError bool
		errorType   error
	}{
		{
			name: "valid user",
			user: User{
				Name:  "John Doe",
				Age:   30,
				Email: "john@example.com",
			},
			expectError: false,
		},
		{
			name: "empty name",
			user: User{
				Name:  "",
				Age:   30,
				Email: "john@example.com",
			},
			expectError: true,
			errorType:   ErrInvalidName,
		},
		{
			name: "invalid age",
			user: User{
				Name:  "John Doe",
				Age:   -1,
				Email: "john@example.com",
			},
			expectError: true,
			errorType:   ErrInvalidAge,
		},
		{
			name: "invalid email",
			user: User{
				Name:  "John Doe",
				Age:   30,
				Email: "invalid-email",
			},
			expectError: true,
			errorType:   ErrInvalidEmail,
		},
		{
			name: "not valid email",
			user: User{
				Name:  "John Doe",
				Age:   30,
				Email: "john@notvalid",
			},
			expectError: true,
			errorType:   ErrInvalidEmail,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.user.Validate()

			if tt.expectError {
				if err == nil {
					t.Error("Expected error, got none")
				}
				if err != tt.errorType {
					t.Errorf("Expected error %v, got %v", tt.errorType, err)
				}
				return
			}

			if err != nil {
				t.Errorf("Unexpected error: %v", err)
			}
		})
	}
}

func TestUserString(t *testing.T) {
	tests := []struct {
		name     string
		user     User
		expected string
	}{
		{
			name: "valid user",
			user: User{
				Name:  "John Doe",
				Age:   30,
				Email: "john@example.com",
			},
			expected: "Name: John Doe, Age: 30, Email: john@example.com",
		},
		{
			name: "user with zero age",
			user: User{
				Name:  "Baby",
				Age:   0,
				Email: "baby@example.com",
			},
			expected: "Name: Baby, Age: 0, Email: baby@example.com",
		},
		{
			name: "user with special characters",
			user: User{
				Name:  "José María",
				Age:   25,
				Email: "jose.maria@example.com",
			},
			expected: "Name: José María, Age: 25, Email: jose.maria@example.com",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := tt.user.String(); got != tt.expected {
				t.Errorf("User.String() = %v, want %v", got, tt.expected)
			}
		})
	}
}
