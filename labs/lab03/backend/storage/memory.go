package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mu       sync.RWMutex
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
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	result := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		result = append(result, msg)
	}
	return result
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	id := ms.nextID
	ms.nextID++

	msg := models.NewMessage(id, username, content)
	ms.messages[id] = msg

	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	msg.Content = content
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	if _, ok := ms.messages[id]; !ok {
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

// GetAllMessages returns all messages (wrapper for GetAll)
func (ms *MemoryStorage) GetAllMessages() ([]*models.Message, error) {
	return ms.GetAll(), nil
}

// CreateMessage creates a new message (wrapper for Create)
func (ms *MemoryStorage) CreateMessage(username, content string) (*models.Message, error) {
	return ms.Create(username, content)
}

// UpdateMessage updates a message (wrapper for Update)
func (ms *MemoryStorage) UpdateMessage(id int, content string) (*models.Message, error) {
	return ms.Update(id, content)
}

// DeleteMessage deletes a message (wrapper for Delete)
func (ms *MemoryStorage) DeleteMessage(id int) error {
	return ms.Delete(id)
}

// CountMessages returns total number of messages (wrapper for Count)
func (ms *MemoryStorage) CountMessages() (int, error) {
	return ms.Count(), nil
}
