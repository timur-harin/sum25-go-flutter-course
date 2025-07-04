package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
	"time"
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

	msgs := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		msgs = append(msgs, msg)
	}
	return msgs
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	id := ms.nextID
	ms.nextID++

	newMsg := models.NewMessage(id, username, content)
	ms.messages[id] = newMsg

	return newMsg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}

	msg.Content = content
	msg.Timestamp = time.Now()
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if _, exists := ms.messages[id]; !exists {
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
