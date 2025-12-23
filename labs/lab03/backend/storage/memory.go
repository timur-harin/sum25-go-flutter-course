package storage

import (
	"errors"
	"sync"

	"lab03-backend/models"
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
		messages: make(map[int]*models.Message),
		nextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	all := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		all = append(all, msg)
	}
	return all
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	if id <= 0 {
		return nil, ErrInvalidID
	}
	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	msg := models.NewMessage(ms.nextID, username, content)
	ms.messages[ms.nextID] = msg
	ms.nextID++
	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if id <= 0 {
		return nil, ErrInvalidID
	}
	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	msg.Content = content
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if id <= 0 {
		return ErrInvalidID
	}
	if _, ok := ms.messages[id]; !ok {
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
