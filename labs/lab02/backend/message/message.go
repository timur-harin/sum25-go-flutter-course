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
	mutex    sync.RWMutex // for accessing messages
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()                       // Write operation -> lock for all operations
	s.messages = append(s.messages, msg) // Add the message
	s.mutex.Unlock()                     // Job is done -> Unlock

	return nil // OK - no error
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	res := make([]Message, 0, 100) // Since max messages number is 100

	s.mutex.RLock() // For thread safety
	for _, msg := range s.messages {
		if len(user) != 0 && msg.Sender != user { // Unneeded message
			continue
		}

		// OK -> add the message
		res = append(res, msg)
	}
	s.mutex.RUnlock()

	return res, nil
}
