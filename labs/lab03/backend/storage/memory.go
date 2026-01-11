package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	// TODO: Add mutex field for thread safety (sync.RWMutex)
	mutex sync.RWMutex
	// TODO: Add messages field as map[int]*models.Message
	messages map[int]*models.Message
	// TODO: Add nextID field of type int for auto-incrementing IDs
	nextID int
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
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	// Convert map values to slice
	messages := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		messages = append(messages, msg)
	}
	// Return slice of all messages
	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	// Use read lock for thread safety
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	// Check if message exists in map
	msg, ok := ms.messages[id]
	if !ok {
		// Return message or error if not found
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	// TODO: Implement Create method
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	// Get next available ID
	id := ms.nextID
	// Create new message using models.NewMessage
	newMessage := models.NewMessage(id, username, content)
	// Add message to map
	ms.messages[id] = newMessage
	// Increment nextID
	ms.nextID++
	// Return created message
	return newMessage, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	// Check if message exists
	msg, ok := ms.messages[id]
	if !ok {
		// Return updated message or error if not found
		return nil, ErrMessageNotFound
	}

	// Update the content field
	msg.Content = content
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	// Check if message exists
	if _, ok := ms.messages[id]; !ok {
		// Return error if message not found
		return ErrMessageNotFound
	}
	// Delete from map
	delete(ms.messages, id)
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	// Use read lock for thread safety
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()
	// Return length of messages map
	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
