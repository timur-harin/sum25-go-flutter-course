package models

import (
	"errors"
	"time"
)

type Message struct {
	ID        int       `json:"id"`
	Username  string    `json:"username"`
	Content   string    `json:"content"`
	Timestamp time.Time `json:"timestamp"`
}

type CreateMessageRequest struct {
	Username string `json:"username"`
	Content  string `json:"content"`
}

type UpdateMessageRequest struct {
	Content string `json:"content"`
}

type HTTPStatusResponse struct {
	StatusCode  int    `json:"status_code"`
	ImageURL    string `json:"image_url"`
	Description string `json:"description"`
}

type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

func NewMessage(id int, username, content string) *Message {
	return &Message{
		ID:        id,
		Username:  username,
		Content:   content,
		Timestamp: time.Now(),
	}
}

func (r *CreateMessageRequest) Validate() error {
	if r.Username == "" {
		return errors.New("username is required")
	}
	if r.Content == "" {
		return errors.New("content is required")
	}
	return nil
}

func (r *UpdateMessageRequest) Validate() error {
	if r.Content == "" {
		return errors.New("content is required")
	}
	return nil
}
