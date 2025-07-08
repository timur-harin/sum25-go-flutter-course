package message

import (
	"errors"
	"sync"
	"time"
)

var(
	ErrEmptyMessageData = errors.New("sender and content must not be empty")
	ErrInvalidSender  = errors.New("invalid sender: must be at least 1 character")
	ErrInvalidContent   = errors.New("invalid content: must be at least 1 character")
	ErrInvalidTime = errors.New("time should be more than 0")
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
}

func NewMessage(sender string, content string, time int64) (Message, error){
	err := Verify(sender, content, time)
	if err != nil{
		return Message{}, err
	}
	return Message{
		Sender: sender,
		Content: content,
		Timestamp: time,
	}, nil
}

func Verify(sender string, content string, time int64) error{
	if !VerifyContent(content){
		return ErrInvalidContent
	}
	if !VerifySender(sender){
		return ErrInvalidSender
	}
	if !VerifyTime(time){
		return ErrInvalidTime
	}
	return nil
}

func VerifySender(sender string) bool{
	return len(sender) >= 1
}

func VerifyContent(content string) bool{
	return len(content) >= 1
}

func VerifyTime(time int64) bool{
	return time > 0
}

// NewMessageStore creates a new MessageStore
func NewMessageStore() *MessageStore {
	return &MessageStore{
		messages: make([]Message, 0, 100),
		mutex: sync.RWMutex{},
	}
}

// AddMessage stores a new message
func (s *MessageStore) AddMessage(msg Message) error {
	if msg.Sender == "" || msg.Content == "" {
		return ErrEmptyMessageData
	}

	if msg.Timestamp == 0 {
		msg.Timestamp = time.Now().Unix()
	}

	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.messages = append(s.messages, msg)
	return nil
}

// GetMessages retrieves messages (optionally by user)
func (s *MessageStore) GetMessages(user string) ([]Message, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	if user == "" {
		return append([]Message(nil), s.messages...), nil
	}

	filtered := make([]Message, 0)
	for _, msg := range s.messages {
		if msg.Sender == user {
			filtered = append(filtered, msg)
		}
	}
	return filtered, nil
}
