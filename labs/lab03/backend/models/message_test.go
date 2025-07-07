package models

import (
	"testing"
	"time"
)

func TestNewMessage(t *testing.T) {
	// Test creating a new message
	id := 1
	username := "testuser"
	content := "test content"

	message := NewMessage(id, username, content)

	if message == nil {
		t.Fatal("NewMessage returned nil")
	}

	if message.ID != id {
		t.Errorf("Expected ID %d, got %d", id, message.ID)
	}

	if message.Username != username {
		t.Errorf("Expected username %s, got %s", username, message.Username)
	}

	if message.Content != content {
		t.Errorf("Expected content %s, got %s", content, message.Content)
	}

	// Check if timestamp is recent (within last 5 seconds)
	now := time.Now()
	if now.Sub(message.Timestamp) > 5*time.Second {
		t.Error("Message timestamp is not recent")
	}
}

func TestCreateMessageRequestValidation(t *testing.T) {
	tests := []struct {
		name      string
		request   CreateMessageRequest
		shouldErr bool
	}{
		{
			name: "valid request",
			request: CreateMessageRequest{
				Username: "testuser",
				Content:  "test content",
			},
			shouldErr: false,
		},
		{
			name: "empty username",
			request: CreateMessageRequest{
				Username: "",
				Content:  "test content",
			},
			shouldErr: true,
		},
		{
			name: "empty content",
			request: CreateMessageRequest{
				Username: "testuser",
				Content:  "",
			},
			shouldErr: true,
		},
		{
			name: "both empty",
			request: CreateMessageRequest{
				Username: "",
				Content:  "",
			},
			shouldErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()
			if tt.shouldErr && err == nil {
				t.Error("Expected validation error, got nil")
			}
			if !tt.shouldErr && err != nil {
				t.Errorf("Expected no validation error, got: %v", err)
			}
		})
	}
}

func TestUpdateMessageRequestValidation(t *testing.T) {
	tests := []struct {
		name      string
		request   UpdateMessageRequest
		shouldErr bool
	}{
		{
			name: "valid request",
			request: UpdateMessageRequest{
				Content: "updated content",
			},
			shouldErr: false,
		},
		{
			name: "empty content",
			request: UpdateMessageRequest{
				Content: "",
			},
			shouldErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.request.Validate()
			if tt.shouldErr && err == nil {
				t.Error("Expected validation error, got nil")
			}
			if !tt.shouldErr && err != nil {
				t.Errorf("Expected no validation error, got: %v", err)
			}
		})
	}
}
