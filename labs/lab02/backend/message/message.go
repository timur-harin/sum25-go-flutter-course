package message

import "sync"

// Message represents a chat message record.
type Message struct {
	Sender    string // user ID
	Content   string
	Timestamp int64
}

// MessageStore holds messages and protects them with a mutex.
type MessageStore struct {
	messages []Message
	mutex    sync.RWMutex
}

// NewMessageStore initializes an empty store.
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
	}
}

// AddMessage appends a message in a thread-safe manner.
func (s *MessageStore) AddMessage(msg Message) error {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages returns all messages if user=="", or filters by Sender otherwise.
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		// return a copy to avoid external mutation
		cpy := make([]Message, len(s.messages))
		copy(cpy, s.messages)
		return cpy, nil
	}

	var filtered []Message
	for _, m := range s.messages {
		if m.Sender == user {
			filtered = append(filtered, m)
		}
	}
	return filtered, nil
}
