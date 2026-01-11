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

// GetMessages retrieves messages.
// If user is empty string, returns all messages.
// Otherwise, returns messages only from that user.
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		// Return a copy to avoid race if caller mutates
		cpy := make([]Message, len(s.messages))
		copy(cpy, s.messages)
		return cpy, nil
	}

	// Filter by user
	filtered := make([]Message, 0, len(s.messages))
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}
	return filtered, nil
}
