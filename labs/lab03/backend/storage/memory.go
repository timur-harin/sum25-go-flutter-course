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
	// TODO: Return a new MemoryStorage instance with initialized fields
	// Initialize messages as empty map
	// Set nextID to 1
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
	// Return slice of all messages
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	messages := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		messages = append(messages, msg)
	}
	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	// Use read lock for thread safety
	// Check if message exists in map
	// Return message or error if not found
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	if msg, exists := ms.messages[id]; exists {
		return msg, nil
	}
	return nil, ErrMessageNotFound
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	// TODO: Implement Create method
	// Use write lock for thread safety
	// Get next available ID
	// Create new message using models.NewMessage
	// Add message to map
	// Increment nextID
	// Return created message
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	newMessage := models.NewMessage(ms.nextID, username, content)
	ms.messages[ms.nextID] = newMessage
	ms.nextID++
	return newMessage, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	// Use write lock for thread safety
	// Check if message exists
	// Update the content field
	// Return updated message or error if not found
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	if msg, exists := ms.messages[id]; exists {
		msg.Content = content
		return msg, nil
	}
	return nil, ErrMessageNotFound
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	if _, exists := ms.messages[id]; exists {
		delete(ms.messages, id)
		return nil
	}
	return ErrMessageNotFound
	// Check if message exists
	// Delete from map
	// Return error if message not found
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	// Use read lock for thread safety
	// Return length of messages map
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
