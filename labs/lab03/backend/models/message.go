package models

import (
	"errors"
	"time"
)

// Message represents a chat message
type Message struct {
	// ID is the unique identifier of the message
	ID        int       `json:"id"`
	// Username of the message author
	Username  string    `json:"username"`
	// Content of the message
	Content   string    `json:"content"`
	// Timestamp when the message was created
	Timestamp time.Time `json:"timestamp"`
}

// CreateMessageRequest represents the request to create a new message
type CreateMessageRequest struct {
	// Username of the author (required)
	Username string `json:"username" validate:"required"`
	// Content of the message (required)
	Content  string `json:"content" validate:"required"`
}

// UpdateMessageRequest represents the request to update a message
type UpdateMessageRequest struct {
	// New content for the message (required)
	Content string `json:"content" validate:"required"`
}

// HTTPStatusResponse represents the response for HTTP status code endpoint
type HTTPStatusResponse struct {
	// StatusCode is the HTTP status code
	StatusCode  int    `json:"status_code"`
	// ImageURL points to a visual representation of the status
	ImageURL    string `json:"image_url"`
	// Description of the status code
	Description string `json:"description"`
}

// APIResponse represents a generic API response
type APIResponse struct {
	// Success indicates whether the request was processed successfully
	Success bool        `json:"success"`
	// Data holds the response payload when Success is true
	Data    interface{} `json:"data,omitempty"`
	// Error holds the error message when Success is false
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
	if r.Username == "" {
		return errors.New("username is required")
	}
	if r.Content == "" {
		return errors.New("content is required")
	}
	return nil
}

// Validate checks if the update message request is valid
func (r *UpdateMessageRequest) Validate() error {
	if r.Content == "" {
		return errors.New("content is required")
	}
	return nil
}
