package message

import (
	"sync"
	"time"
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
}

func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

func (s *MessageStore) AddMessage(msg Message) error {
	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
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
		copyMsgs := make([]Message, len(s.messages))
		copy(copyMsgs, s.messages)
		return copyMsgs, nil
	}

	filtered := []Message{}
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}

	return filtered, nil
}
