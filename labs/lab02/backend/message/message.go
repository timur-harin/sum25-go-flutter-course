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

// AddMessage stores a new message in a thread-safe manner
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages, optionally filtered by user
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	// If no user is specified, return all messages.
	// We create a copy to prevent race conditions if the caller modifies the slice.
	if user == "" {
		allMessages := make([]Message, len(s.messages))
		copy(allMessages, s.messages)
		return allMessages, nil
	}

	// Filter messages by the specified user.
	var userMessages []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			userMessages = append(userMessages, msg)
		}
	}

	if len(userMessages) == 0 {
		// It's not an error if a user has no messages, just return an empty slice.
		return []Message{}, nil
	}

	return userMessages, nil
}
