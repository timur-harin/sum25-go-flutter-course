package message

import (
	"sync"
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
	messages := make([]Message, 0, 100)
	s.mutex.RLock()
	defer s.mutex.RUnlock()
	if user == "" {
		for _, msg := range s.messages {
			messages = append(messages, msg)
		}
	} else {
		for _, msg := range s.messages {
			if msg.Sender == user {
				messages = append(messages, msg)
			}
		}
	}
	return messages, nil
}
