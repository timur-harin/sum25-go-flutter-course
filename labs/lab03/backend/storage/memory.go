package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	// TODO: Add mutex field for thread safety (sync.RWMutex)
	// TODO: Add messages field as map[int]*models.Message
	// TODO: Add nextID field of type int for auto-incrementing IDs
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
	// TODO: Implement GetAll method
	// Use read lock for thread safety
	// Convert map values to slice
	// Return slice of all messages]
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	result := make([]*models.Message, 0, len(ms.messages))
	for _, message := range ms.messages {
		result = append(result, message)
	}
	return result
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	// Use read lock for thread safety
	// Check if message exists in map
	// Return message or error if not found
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	if ms.messages[id] != nil {
		return ms.messages[id], nil
	} else {
		return nil, ErrMessageNotFound
	}
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	// Get next available ID
	id := ms.nextID

	// Create new message using models.NewMessage
	message := models.NewMessage(id, username, content)

	// Add message to map
	ms.messages[id] = message

	// Increment nextID
	ms.nextID++

	// Return created message
	return message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	// Check if message exists
	if ms.messages[id] != nil {
		ms.messages[id].Content = content
		return ms.messages[id], nil
	} else {
		return nil, ErrMessageNotFound
	}
	// Update the content field
	// Return updated message or error if not found
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	if ms.messages[id] != nil {
		delete(ms.messages, id)
		return nil
	} else {
		return ErrMessageNotFound
	}
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
