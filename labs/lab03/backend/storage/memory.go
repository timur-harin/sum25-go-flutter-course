package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mutex    sync.RWMutex
	messages map[int]*models.Message
	nextID   int
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		mutex:    sync.RWMutex{},
		messages: make(map[int]*models.Message),
		nextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	var msgSlice []*models.Message

	for _, message := range ms.messages {
		msgSlice = append(msgSlice, message)
	}

	return msgSlice
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	if msg, exists := ms.messages[id]; exists {
		return msg, nil
	} else {
		return nil, ErrMessageNotFound
	}
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if !models.IsValidUsername(username) {
		return nil, models.ErrEmptyUsername
	}

	if !models.IsValidContent(content) {
		return nil, models.ErrEmptyContent
	}

	ms.messages[ms.nextID] = models.NewMessage(ms.nextID, username, content)
	ms.nextID += 1

	return ms.messages[ms.nextID-1], nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	if !isValidID(id) {
		return nil, ErrInvalidID
	}

	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if msg, exists := ms.messages[id]; exists {
		msg.Content = content
		return msg, nil
	} else {
		return nil, ErrMessageNotFound
	}
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	if !isValidID(id) {
		return ErrInvalidID
	}

	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if _, exists := ms.messages[id]; exists {
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

// there isValidID checks if the provided ID is valid
func isValidID(id int) bool {
	return id > 0
}
