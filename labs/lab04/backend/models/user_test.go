package models

import (
	"testing"
	"time"
)

func TestUser_Validate(t *testing.T) {
	tests := []struct {
		name    string
		user    User
		wantErr bool
	}{
		{
			name: "valid user",
			user: User{
				Name:  "John Doe",
				Email: "john@example.com",
			},
			wantErr: false,
		},
		{
			name: "empty name",
			user: User{
				Name:  "",
				Email: "john@example.com",
			},
			wantErr: true,
		},
		{
			name: "short name",
			user: User{
				Name:  "J",
				Email: "john@example.com",
			},
			wantErr: true,
		},
		{
			name: "invalid email",
			user: User{
				Name:  "John Doe",
				Email: "not-an-email",
			},
			wantErr: true,
		},
		{
			name: "empty email",
			user: User{
				Name:  "John Doe",
				Email: "",
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.user.Validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("User.Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestCreateUserRequest_Validate(t *testing.T) {
	tests := []struct {
		name    string
		req     CreateUserRequest
		wantErr bool
	}{
		{
			name: "valid request",
			req: CreateUserRequest{
				Name:  "John Doe",
				Email: "john@example.com",
			},
			wantErr: false,
		},
		{
			name: "empty name",
			req: CreateUserRequest{
				Name:  "",
				Email: "john@example.com",
			},
			wantErr: true,
		},
		{
			name: "invalid email",
			req: CreateUserRequest{
				Name:  "John Doe",
				Email: "invalid-email",
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.req.Validate()
			if (err != nil) != tt.wantErr {
				t.Errorf("CreateUserRequest.Validate() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestCreateUserRequest_ToUser(t *testing.T) {
	req := CreateUserRequest{
		Name:  "John Doe",
		Email: "john@example.com",
	}

	user := req.ToUser()
	if user == nil {
		t.Fatal("ToUser() returned nil")
	}

	if user.Name != req.Name {
		t.Errorf("ToUser() name = %v, want %v", user.Name, req.Name)
	}

	if user.Email != req.Email {
		t.Errorf("ToUser() email = %v, want %v", user.Email, req.Email)
	}

	// Check that timestamps are set
	if user.CreatedAt.IsZero() {
		t.Error("ToUser() CreatedAt should not be zero")
	}

	if user.UpdatedAt.IsZero() {
		t.Error("ToUser() UpdatedAt should not be zero")
	}

	// Check that timestamps are recent (within last minute)
	now := time.Now()
	if now.Sub(user.CreatedAt) > time.Minute {
		t.Error("ToUser() CreatedAt should be recent")
	}

	if now.Sub(user.UpdatedAt) > time.Minute {
		t.Error("ToUser() UpdatedAt should be recent")
	}
}
