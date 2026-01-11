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
	Mutex    sync.RWMutex
	Messages map[int]*models.Message
	nextID   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	// TODO: Return a new MemoryStorage instance with initialized fields
	// Initialize messages as empty map
	// Set nextID to 1
	ms := new(MemoryStorage)
	ms.nextID = 1
	ms.Messages = make(map[int]*models.Message)
	return ms
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	// TODO: Implement GetAll method
	// Use read lock for thread safety
	// Convert map values to slice
	// Return slice of all messages
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()

	var sliceMessage []*models.Message
	for _, msg := range ms.Messages {
		sliceMessage = append(sliceMessage, msg)
	}
	return sliceMessage
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	// Use read lock for thread safety
	// Check if message exists in map
	// Return message or error if not found
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()

	msg, ok := ms.Messages[id]
	if !ok {
		return nil, ErrInvalidID
	}
	return msg, nil
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
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	nextAvailableID := ms.nextID
	newMessage := models.NewMessage(nextAvailableID, username, content)
	ms.Messages[nextAvailableID] = newMessage
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
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	_, ok := ms.Messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}

	ms.Messages[id].Content = content
	return ms.Messages[id], nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	_, ok := ms.Messages[id]
	if !ok {
		return ErrMessageNotFound
	}

	delete(ms.Messages, id)
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	// Use read lock for thread safety
	// Return length of messages map
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()
	return len(ms.Messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
