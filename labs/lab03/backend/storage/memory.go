package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mutex    sync.RWMutex
	messages map[int]*models.Message
	nextID   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		messages: make(map[int]*models.Message, 0),
		nextID:   1,
	}
}

// GetAll returns all messages
func (m *MemoryStorage) GetAll() []*models.Message {
	msgs := make([]*models.Message, 0, len(m.messages))
	for _, msg := range m.messages {
		msgs = append(msgs, msg)
	}
	return msgs
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	req := &models.CreateMessageRequest{
		Username: username,
		Content:  content,
	}

	if err := req.Validate(); err != nil {
		return nil, err
	}

	msg := models.NewMessage(
		ms.nextID,
		username,
		content,
	)

	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	ms.messages[ms.nextID] = msg
	ms.nextID++

	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	req := &models.UpdateMessageRequest{
		Content: content,
	}
	if err := req.Validate(); err != nil {
		return nil, err
	}

	msg, err := ms.GetByID(id)
	if err != nil {
		return nil, err
	}

	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	msg.Content = content
	ms.messages[msg.ID] = msg

	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	_, ok := ms.messages[id]
	if !ok {
		return ErrMessageNotFound
	}
	delete(ms.messages, id)

	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
