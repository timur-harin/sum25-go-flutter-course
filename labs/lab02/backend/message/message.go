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
	s.messages = append(s.messages, msg)
	s.mutex.Unlock()
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	if user == "" {
		return s.messages, nil
	}
	messages := make([]Message, 0, 100)
	s.mutex.Lock()
	for _, message := range s.messages {
		if message.Sender == user {
			messages = append(messages, message)
		}
	}
	s.mutex.Unlock()
	return messages, nil
}
