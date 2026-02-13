package message

import (
	"errors"
	"sync"
	"time"
)

// Message represents a chat message
type Message struct {
	Sender    string
	Content   string
	Timestamp int64
}

// MessageStore stores chat messages
type MessageStore struct {
	messages []Message
	mutex    sync.RWMutex
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if msg.Sender == "" {
		return errors.New("sender cannot be empty")
	}

	if msg.Content == "" {
		return errors.New("content cannot be empty")
	}

	// Set timestamp if not provided
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
	}

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	result := make([]Message, 0)

	if user == "" {
		// Return all messages
		result = append(result, s.messages...)
		return result, nil
	}

	// Filter by user
	for _, msg := range s.messages {
		if msg.Sender == user {
			result = append(result, msg)
		}
	}

	if len(result) == 0 {
		return nil, errors.New("no messages found")
	}

	return result, nil
}