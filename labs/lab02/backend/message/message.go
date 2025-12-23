package message

import (
	"errors"
	"sync"
)

// Message represents a chat message

var (
	ErrEmptySender   = errors.New("sender cannot be empty")
	ErrEmptyContent  = errors.New("content cannot be empty")
	ErrInvalidTimestamp = errors.New("timestamp must be positive")
)

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
	maxSize  int
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0),
		maxSize:  1000,
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	if msg.Sender == "" {
		return ErrEmptySender
	}
	if msg.Content == "" {
		return ErrEmptyContent
	}
	if msg.Timestamp < 0 {
		return ErrInvalidTimestamp
	}
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if len(s.messages) >= s.maxSize {
		return errors.New("message storage limit reached")
	}

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()
	
	if user == "" {
		messages := make([]Message, len(s.messages))
		copy(messages, s.messages)
		return messages, nil
	}
	
	var userMassages []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			userMassages = append(userMassages, msg)
		}
	}
	return userMassages, nil
}
