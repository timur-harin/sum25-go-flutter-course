package message

import (
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
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}
	var filtered []Message
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}
	return filtered, nil
}
