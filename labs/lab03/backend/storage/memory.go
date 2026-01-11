package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	Mutex    sync.RWMutex
	Messages map[int]*models.Message
	NextID   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		Messages: make(map[int]*models.Message),
		NextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	var messages []*models.Message
	for _, message := range ms.Messages {
		messages = append(messages, message)
	}

	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	if id < 1 {
		return nil, ErrInvalidID
	}

	if _, ok := ms.Messages[id]; !ok {
		return nil, ErrMessageNotFound
	}

	return ms.Messages[id], nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	next := ms.NextID
	message := models.NewMessage(next, username, content)
	ms.Messages[next] = message
	ms.NextID += 1

	return message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	if id < 1 {
		return nil, ErrInvalidID
	}

	if _, ok := ms.Messages[id]; !ok {
		return nil, ErrMessageNotFound
	}

	ms.Messages[id].Content = content

	return ms.Messages[id], nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	if id < 1 {
		return ErrInvalidID
	}

	if _, ok := ms.Messages[id]; !ok {
		return ErrMessageNotFound
	}

	delete(ms.Messages, id)

	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	return len(ms.Messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
