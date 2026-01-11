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
	if msg.Sender == "" || msg.Content == "" {
		return errors.New("sender and content cannot be empty")
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

	if len(s.messages) == 0 {
		return nil, errors.New("no messages available")
	}

	// If no user specified, return all messages
	if user == "" {
		// Return a copy to avoid external modifications
		messages := make([]Message, len(s.messages))
		copy(messages, s.messages)
		return messages, nil
	}

	// Filter messages by user
	var filtered []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	if len(filtered) == 0 {
		return nil, errors.New("no messages found for the specified user")
	}

	return filtered, nil
}
