package message

import (
	"errors"
	"sync"
)

type Message struct {
	Sender    string
	Content   string
	Timestamp int64
}

type MessageStore struct {
	messages []Message
	mutex    sync.RWMutex
}

func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.messages = append(s.messages, msg)
	return nil
}

func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if len(s.messages) == 0 {
		return nil, errors.New("no messages available")
	}

	if user == "" {
		// Return all messages
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}

	var filtered []Message
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}

	if len(filtered) == 0 {
		return nil, errors.New("no messages for specified user")
	}

	return filtered, nil
}
