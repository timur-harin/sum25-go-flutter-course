package models

import (
	"errors"
	"fmt"
	"strings"
	"time"
)

// Message represents a chat message
type Message struct {
	ID        int       `json:"id"`
	Username  string    `json:"username"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
}

// CreateMessageRequest represents the request to create a new message
type CreateMessageRequest struct {
	Username string `json:"username" validate:"required"`
	Content  string `json:"content" validate:"required"`
}

// UpdateMessageRequest represents the request to update a message
type UpdateMessageRequest struct {
	Content string `json:"content" validate:"required"`
}

// HTTPStatusResponse represents the response for HTTP status code endpoint
type HTTPStatusResponse struct {
	StatusCode  int    `json:"status_code"`
	ImageURL    string `json:"image_url"`
	Description string `json:"description"`
}

// APIResponse represents a generic API response
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// NewMessage creates a new message with the current timestamp
func NewMessage(id int, username, content string) *Message {
	return &Message{
		ID:        id,
		Username:  username,
		Content:   content,
		Timestamp: time.Now(),
	}
}

// Validate checks if the create message request is valid
func (r *CreateMessageRequest) Validate() error {
	if strings.TrimSpace(r.Username) == "" {
		return errors.New("username is required")
	}
	if strings.TrimSpace(r.Content) == "" {
		return errors.New("content is required")
	}
	if len(r.Username) > 50 {
		return errors.New("username must be less than 50 characters")
	}
	if len(r.Content) > 500 {
		return errors.New("content must be less than 500 characters")
	}
	return nil
}

// Validate checks if the update message request is valid
func (r *UpdateMessageRequest) Validate() error {
	if strings.TrimSpace(r.Content) == "" {
		return errors.New("content is required")
	}
	if len(r.Content) > 500 {
		return errors.New("content must be less than 500 characters")
	}
	return nil
}

// String provides a string representation of the message
func (m *Message) String() string {
	return fmt.Sprintf("[%d] %s (%s): %s", m.ID, m.Username, m.Timestamp.Format("2006-01-02 15:04:05"), m.Content)
}
