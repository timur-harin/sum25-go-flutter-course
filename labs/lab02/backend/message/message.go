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

	if user == "" {
		result := make([]Message, len(s.messages))
		copy(result, s.messages)
		return result, nil
	}

	var result []Message
	for _, m := range s.messages {
		if m.Sender == user {
			result = append(result, m)
		}
	}

	return result, nil
}
