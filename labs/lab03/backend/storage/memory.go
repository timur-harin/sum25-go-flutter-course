package storage

import (
	"errors"
	"fmt"
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
		mu:       sync.RWMutex{},
		messages: make(map[int]*models.Message),
		nextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	var messages []*models.Message
	for _, msg := range ms.messages {
		messages = append(messages, msg)
	}

	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	if msg, exists := ms.messages[id]; exists {
		return msg, nil
	}

	return nil, ErrMessageNotFound
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	msg := models.NewMessage(ms.nextID, username, content)
	fmt.Printf("Creating message: ID=%d, Username=%s, Content=%s\n", msg.ID, msg.Username, msg.Content) // Логирование

	ms.messages[ms.nextID] = msg
	ms.nextID++
	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	if msg, exists := ms.messages[id]; exists {
		msg.Content = content
		return msg, nil
	}

	return nil, ErrMessageNotFound
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	if _, exists := ms.messages[id]; exists {
		delete(ms.messages, id)
		return nil
	}
	return ErrMessageNotFound
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
