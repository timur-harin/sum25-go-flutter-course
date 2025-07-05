package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mut sync.RWMutex
	messages map[int]*models.Message
	nextID int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		messages: make(map[int]*models.Message),
		nextID: 1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mut.RLock()
	defer ms.mut.RUnlock()
	
	messages := make([]*models.Message, 0, len(ms.messages))
	for _, message := range(ms.messages) {
		messages = append(messages, message)
	}
	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mut.RLock()
	defer ms.mut.RUnlock()
	
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrInvalidID
	}
	
	return message, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mut.Lock()
	defer ms.mut.Unlock()
	
	id := ms.nextID
	
	message := models.NewMessage(id, username, content)
	
	ms.messages[id] = message
	ms.nextID++
	
	return message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mut.Lock()
	defer ms.mut.Unlock()
	
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrInvalidID
	}
	
	message.Content = content
	
	return message, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mut.Lock()
	defer ms.mut.Unlock()
	
	_, ok := ms.messages[id]
	if !ok {
		return ErrInvalidID
	}
	
	delete(ms.messages, id)
	
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	ms.mut.RLock()
	defer ms.mut.RUnlock()
	
	return len(ms.messages)
}

// Common errors
var (
	ErrInvalidID = errors.New("invalid message ID")
)
