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

// MessageStore stores chat messages safely for concurrent access
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

// AddMessage stores a new message (concurrency safe)
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves all messages or only those by the specified user if user != ""
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		// Return copy of all messages
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}

	// Filter messages by sender
	filtered := make([]Message, 0, len(s.messages))
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}
	return filtered, nil
}
