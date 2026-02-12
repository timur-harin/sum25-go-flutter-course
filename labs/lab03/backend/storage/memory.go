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
	newMemoryStorage := &MemoryStorage{sync.RWMutex{}, make(map[int]*models.Message), 0}
	newMemoryStorage.nextID = 1
	return newMemoryStorage
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	slice_messages := make([]*models.Message, 0, len(ms.messages))
	ms.mutex.RLock()
	for _, value := range ms.messages {
		slice_messages = append(slice_messages, value)
	}
	ms.mutex.RUnlock()
	return slice_messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	if id < 0 || id > ms.nextID {
		return nil, ErrInvalidID
	}
	ms.mutex.RLock()
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	ms.mutex.RUnlock()
	return message, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	message := &models.Message{ID: ms.nextID, Username: username, Content: content, Timestamp: time.Now()}
	ms.messages[message.ID] = message
	ms.nextID++
	ms.mutex.Unlock()
	return message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	if id < 0 || id > ms.nextID {
		return nil, ErrInvalidID
	}
	ms.mutex.Lock()
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	message.Content = content
	ms.mutex.Unlock()
	return message, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	if id < 0 || id > ms.nextID {
		return ErrInvalidID
	}
	ms.mutex.RLock()
	_, ok := ms.messages[id]
	ms.mutex.RUnlock()
	if !ok {
		return ErrMessageNotFound
	}
	ms.mutex.Lock()
	delete(ms.messages, id)
	ms.mutex.Unlock()
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
