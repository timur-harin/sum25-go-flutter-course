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

// MessageStore stores chat messages with thread safety
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

// AddMessage adds a message to the store in a thread-safe way
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages sent by a specific user
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	var result []Message
	for _, m := range s.messages {
		if m.Sender == user || user == "" {
			result = append(result, m)
		}
	}

	if len(result) == 0 {
		return nil, errors.New("no messages found")
	}
	return result, nil
}
