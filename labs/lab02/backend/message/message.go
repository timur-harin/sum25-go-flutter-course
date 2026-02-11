package message

import (
	"errors"
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
	// TODO: Initialize MessageStore fields
	return &MessageStore{
		messages: make([]Message, 0, 100),
		mutex:    sync.RWMutex{},
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	// TODO: Add message to storage (concurrent safe)
	s.mutex.Lock()
	defer s.mutex.Unlock()

	if msg.Content == "" {
		return errors.New("message content cannot be empty")
	}
	if msg.Sender == "" {
		return errors.New("sender name cannot be empty")

	}

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	// TODO: Retrieve messages (all or by user)
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		msgs := make([]Message, len(s.messages))
		copy(msgs, s.messages)
		return msgs, nil
	}

	msgs := make([]Message, 0, len(s.messages))
	for _, msg := range s.messages {
		if msg.Sender == user {
			msgs = append(msgs, msg)
		}
	}

	if len(msgs) == 0 {
		return nil, errors.New("cannot find any messages by this user")
	}

	return msgs, nil
}
