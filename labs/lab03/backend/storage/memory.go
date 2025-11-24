package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
	"time"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	messages []models.Message
	nextID   int
	mutex    sync.RWMutex
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		messages: make([]models.Message, 0),
		nextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	result := make([]*models.Message, len(ms.messages))
	for i := range ms.messages {
		result[i] = &ms.messages[i]
	}
	return result
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	for _, message := range ms.messages {
		if message.ID == id {
			return &message, nil
		}
	}

	return nil, errors.New("message not found")
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	message := models.Message{
		ID:        ms.nextID,
		Username:  username,
		Content:   content,
		Timestamp: time.Now(),
	}

	ms.messages = append(ms.messages, message)
	ms.nextID++

	return &message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	for i := range ms.messages {
		if ms.messages[i].ID == id {
			ms.messages[i].Content = content
			return &ms.messages[i], nil
		}
	}

	return nil, errors.New("message not found")
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	for i, message := range ms.messages {
		if message.ID == id {
			ms.messages = append(ms.messages[:i], ms.messages[i+1:]...)
			return nil
		}
	}

	return errors.New("message not found")
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
