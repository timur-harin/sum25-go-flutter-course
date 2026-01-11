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

// AddMessage stores a new message (concurrent safe)
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves all messages, or only those by the given user
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
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	return filtered, nil
}
