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

// AddMessage stores a new message (thread-safe)
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves all messages or messages from a specific user
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		// return a copy of all messages
		all := make([]Message, len(s.messages))
		copy(all, s.messages)
		return all, nil
	}

	// filter by sender
	var filtered []Message
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}
	return filtered, nil
}