package message

import (
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
		return []Message{}, nil
	}

	if user == "" {
		messages := make([]Message, len(s.messages))
		copy(messages, s.messages)
		return messages, nil
	}
	result := make([]Message, 0, len(s.messages)/2)
	for _, msg := range s.messages {
		if msg.Sender == user {
			result = append(result, msg)
		}
	}
	return result, nil
}
