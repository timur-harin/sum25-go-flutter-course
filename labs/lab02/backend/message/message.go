package message

import (
	"errors"
	"sync"
)

// Predefined errors
var (
	ErrEmptySender      = errors.New("empty sender name")
	ErrEmptyContent     = errors.New("empty message content")
	ErrInvalidTimestamp = errors.New("invalid timestamp")
)

// Message represents a chat message
type Message struct {
	Sender    string
	Content   string
	Timestamp int64
}

func isValidMessage(msg Message) error {
	if !isValidSender(msg.Sender) {
		return ErrEmptySender
	}

	if !isValidContent(msg.Content) {
		return errors.New("empty message content")
	}

	if !isValidTimestamp(msg.Timestamp) {
		return errors.New("invalid timestamp")
	}

	return nil
}

// isValidSender checks if the sender name is non-empty
func isValidSender(sender string) bool {
	return len(sender) > 0
}

// isValidContent checks if the message content is non-empty
func isValidContent(content string) bool {
	return len(content) > 0
}

// isValidTimestamp checks if the timestamp is any non-negative integer
func isValidTimestamp(timestamp int64) bool {
	return timestamp >= 0
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
	//if err := isValidMessage(msg); err != nil {
	//	return err
	//}

	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)

	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	var filtered []Message
	for _, msg := range s.messages {
		if user == "" || msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	return filtered, nil
}
