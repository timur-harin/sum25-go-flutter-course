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
		mutex:    sync.RWMutex{},
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	// TODO: Add message to storage (concurrent safe)
	if msg.Sender == "" || msg.Content == "" {
		return errors.New("sender and content cannot be empty")
	}

	s.mutex.Lock()
	s.messages = append(s.messages, msg)
	s.mutex.Unlock()
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	// TODO: Retrieve messages (all or by user)
	result := make([]Message, 0, 100)
	for _, msg := range s.messages {
		if msg.Sender == user || user == "" {
			s.mutex.RLock()
			result = append(result, msg)
			s.mutex.RUnlock()
		}
	}
	if len(result) != 0 {
		return result, nil
	}

	return nil, errors.New("not implemented")
}
