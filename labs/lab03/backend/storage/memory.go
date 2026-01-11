package storage

import (
	"errors"
	// "fmt"
	"lab03-backend/models"
	"sync"
	"time"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	// TODO: Add mutex field for thread safety (sync.RWMutex)
	Mutex sync.RWMutex
	// TODO: Add messages field as map[int]*models.Message
	Messages map[int]*models.Message
	// TODO: Add nextID field of type int for auto-incrementing IDs
	NextID int64
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		Messages: map[int]*models.Message{},
		NextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	// TODO: Implement GetAll method
	var messages []*models.Message
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()
	for _, values := range ms.Messages {
		messages = append(messages, values)
	}
	// fmt.Println(len(messages))
	// Use read lock for thread safety
	// Convert map values to slice
	// Return slice of all messages
	return messages
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	// TODO: Implement GetByID method
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()

	value, ok := ms.Messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}

	return value, nil

	// Use read lock for thread safety
	// Check if message exists in map
	// Return message or error if not found
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	// TODO: Implement Create method
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	nextId := ms.NextID

	message := models.Message{
		ID:       int(nextId),
		Username: username,
		Content:  content,
		Timestamp: time.Now(),
	}

	ms.Messages[int(nextId)] = &message

	ms.NextID++

	// fmt.Println(len(ms.Messages))

	return &message, nil
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	// TODO: Implement Update method
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	if _, ok := ms.Messages[id]; !ok {
		return nil, ErrMessageNotFound
	}

	ms.Messages[id].Content = content

	return ms.Messages[id], nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	ms.Mutex.Lock()
	defer ms.Mutex.Unlock()

	if _, ok := ms.Messages[id]; !ok {
		return ErrMessageNotFound
	}

	delete(ms.Messages, id)

	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	return nil
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	// TODO: Implement Count method
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock()
	// Use read lock for thread safety
	// Return length of messages map
	return len(ms.Messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
