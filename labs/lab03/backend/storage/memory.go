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
	nextId   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	// TODO: Return a new MemoryStorage instance with initialized fields
	// Initialize messages as empty map
	// Set nextID to 1
	memoryStorage := &MemoryStorage{
		messages: make(map[int]*models.Message),
		nextId:   1,
	}
	return memoryStorage
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	// TODO: Implement GetAll method
	// Use read lock for thread safety
	// Convert map values to slice
	// Return slice of all messages
	ms.mutex.RLock()
	var res []*models.Message
	for _, v := range ms.messages {
		res = append(res, v)
	}
	ms.mutex.RUnlock()
	return res
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	// Use read lock for thread safety
	// Check if message exists in map
	// Return message or error if not found
	ms.mutex.RLock()
	m, ok := ms.messages[id]
	ms.mutex.RUnlock()
	if ok {
		return m, nil
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
	id := ms.nextId
	ms.nextId++
	msg := &models.Message{
		ID:       id,
		Username: username,
		Content:  content,
	}
	ms.messages[id] = msg
	ms.mutex.Unlock()
	return msg, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	// Use write lock for thread safety
	// Check if message exists
	// Update the content field
	// Return updated message or error if not found
	ms.mutex.Lock()
	if _, ok := ms.messages[id]; ok {
		ms.messages[id].Content = content
		ms.mutex.Unlock()
		return ms.messages[id], nil
	}
	ms.mutex.Unlock()
	return nil, ErrMessageNotFound
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	ms.mutex.Lock()
	if _, ok := ms.messages[id]; ok {
		delete(ms.messages, id)
		ms.mutex.Unlock()
		return nil
	}
	ms.mutex.Unlock()
	return ErrMessageNotFound
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	// Use read lock for thread safety
	// Return length of messages map
	ms.mutex.RLock()
	l := len(ms.messages)
	ms.mutex.RUnlock()
	return l
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
