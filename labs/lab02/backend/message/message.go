package message

import (
	"errors"
	"sync"
)

// Message represents a chat message
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
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	// Locking editing
	s.mutex.Lock()
	// Unlocking editing after exit from function
	defer s.mutex.Unlock()

	// Validation
	if msg.Sender == "" || msg.Content == "" {
		return errors.New("check sender and content of the message")
	}

	// Adding message
	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	// Check if channel is empty
	if len(s.messages) == 0 {
		return nil, errors.New("no messages available")
	}

	// No filtering by user
	if user == "" {
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}

	// Filtering by user-sender
	var filtered []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	// Check if there are some results of filtering
	if len(filtered) == 0 {
		return nil, errors.New("no messages")
	}

	return filtered, nil
}
