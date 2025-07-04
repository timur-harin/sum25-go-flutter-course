package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mu       sync.RWMutex
	nextID   int
	messages map[int]*models.Message
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		mu:       sync.RWMutex{},
		nextID:   1,
		messages: make(map[int]*models.Message),
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	allMessages := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		allMessages = append(allMessages, msg)
	}
	return allMessages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	msg := models.NewMessage(ms.nextID, username, content)
	ms.messages[ms.nextID] = msg
	ms.nextID++
	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}
	msg.Content = content
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	if _, exists := ms.messages[id]; !exists {
		return ErrMessageNotFound
	}
	delete(ms.messages, id)
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
