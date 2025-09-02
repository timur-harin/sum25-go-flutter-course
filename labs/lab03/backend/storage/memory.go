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
		mutex:    sync.RWMutex{},
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
	if id > ms.nextID-1 || id < 1 {
		return nil, ErrInvalidID
	}
	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
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
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	message := &models.Message{
		ID:       ms.nextID,
		Username: username,
		Content:  content,
	}
	ms.messages[message.ID] = message
	ms.nextID++
	return message, nil
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
	if id > ms.nextID-1 || id < 1 {
		return nil, ErrInvalidID
	}
	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	msg.Content = content
	ms.messages[id] = msg
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	ms.mutex.Lock()
	defer ms.mutex.Unlock()
	if id > ms.nextID-1 || id < 1 {
		return ErrInvalidID
	}
	_, ok := ms.messages[id]
	if !ok {
		return ErrMessageNotFound
	}
	delete(ms.messages, id)
	return nil
}

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
