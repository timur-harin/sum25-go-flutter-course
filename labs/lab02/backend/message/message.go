package message

import (
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
	// Set timestamp if not provided
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
	
	// If no specific user is requested, return all messages
	if user == "" {
		// Create a copy to avoid returning reference to internal slice
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}
	
	// Filter messages by user
	var filtered []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}
	
	return filtered, nil
}
