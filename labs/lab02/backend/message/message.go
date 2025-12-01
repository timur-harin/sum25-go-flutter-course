package message

import (
	"errors"
	"sync"
	"time"
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
	if msg.Sender == "" {
		return errors.New("sender cannot be empty")
	}
	if msg.Content == "" {
		return errors.New("content cannot be empty")
	}
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
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
		// Return all messages
		copied := make([]Message, len(s.messages))
		copy(copied, s.messages)
		return copied, nil
	}

	// Filter by user
	var filtered []Message
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}

	return filtered, nil
}
