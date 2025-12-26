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
	mutex    sync.RWMutex
	messages []Message
}

func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

func (s *MessageStore) AddMessage(msg Message) error {
	if msg.Sender == "" {
		return errors.New("message must have a sender")
	}
	if msg.Content == "" {
		return errors.New("message content cannot be empty")
	}

	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)
	return nil
}

func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		out := make([]Message, len(s.messages))
		copy(out, s.messages)
		return out, nil
	}

	var filtered []Message
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}

	return filtered, nil
}
