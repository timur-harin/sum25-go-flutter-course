package message

import (
	"errors"
	"sync"
)

// Message represents a chat message
// TODO: Add more fields if needed

type Message struct {
	Sender    string
	Content   string
	Timestamp int64
}

// MessageStore stores chat messages
// Contains a slice of messages and a mutex for concurrency

type MessageStore struct {
	messages []Message
	mutex    sync.RWMutex
	// TODO: Add more fields if needed
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	// TODO: Initialize MessageStore fields
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	if msg.Sender == "" || msg.Content == "" {
		return errors.New("invalid message: missing fields")
	}

	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		messagesCopy := make([]Message, len(s.messages))
		copy(messagesCopy, s.messages)
		return messagesCopy, nil
	}

	filtered := make([]Message, 0)
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	return filtered, nil
}
