package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	sync.RWMutex
	messages map[int]*models.Message
	nextId   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	memory := &MemoryStorage{messages: make(map[int]*models.Message), nextId: 1}
	return memory
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.RLock()
	defer ms.RUnlock()
	messages := make([]*models.Message, 0)
	for _, message := range ms.messages {
		messages = append(messages, message)
	}
	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.RLock()
	defer ms.RUnlock()
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	} else {
		return message, nil
	}
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
	ms.Lock()
	defer ms.Unlock()
	newMessage := models.NewMessage(ms.nextId, username, content)
	ms.messages[ms.nextId] = newMessage
	ms.nextId++
	return newMessage, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	// Use write lock for thread safety
	// Check if message exists
	// Update the content field
	// Return updated message or error if not found
	ms.Lock()
	defer ms.Unlock()
	message, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	} else {
		message.Content = content
	}
	return message, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	ms.Lock()
	defer ms.Unlock()
	_, ok := ms.messages[id]
	if !ok {
		return ErrMessageNotFound
	} else {
		delete(ms.messages, id)
	}
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	// Use read lock for thread safety
	// Return length of messages map
	ms.RLock()
	defer ms.RUnlock()
	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
