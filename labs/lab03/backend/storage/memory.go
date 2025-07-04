package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
	"time"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	Mutex    sync.RWMutex            // for "Messages" map and "NextID"
	Messages map[int]*models.Message // ID -> Message mapping
	NextID   int                     // to generate new IDs
}

// NewMemoryStorage creates a new in-memory storage instance
func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		Messages: make(map[int]*models.Message),
		NextID:   1,
	}
}

// GetAll returns all messages
func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock() // To unclock the thread when getting out of the function

	// Create the slice with the needed capacity
	msgs := make([]*models.Message, 0, ms.Count())
	// Fill the slice with the messages
	for _, msg := range ms.Messages {
		msgs = append(msgs, msg)
	}

	// Return the slice with all messages
	return msgs
}

// GetByID returns a message by its ID
func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.Mutex.RLock()
	defer ms.Mutex.RUnlock() // To unclock the thread when getting out of the function

	// Get the value by key "id"
	msg, found := ms.Messages[id]
	if found {
		return msg, nil
	}

	// Unable to find the message
	return nil, ErrMessageNotFound
}

// Create adds a new message to storage
func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.Mutex.Lock()         // Lock for all operations
	defer ms.Mutex.Unlock() // To unclock the thread when getting out of the function

	// Create the message
	msg := models.NewMessage(ms.NextID, username, content)

	ms.Messages[ms.NextID] = msg // Add the message to the map
	ms.NextID++                  // increment the "NextID" field

	return msg, nil // Return the created message
}

// Update modifies an existing message
func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.Mutex.Lock()         // Lock for all operations
	defer ms.Mutex.Unlock() // To unclock the thread when getting out of the function

	// Get the message
	msg, found := ms.Messages[id]
	if !found { // Message not found -> ID may be incorrect
		return nil, ErrInvalidID
	}

	// Change the content (update)
	msg.Content = content
	// Set the "current timestamp"
	msg.Timestamp = time.Now()

	// Since "msg" is a pointer, no more actions are needed -> quit
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	// TODO: Implement Delete method
	// Use write lock for thread safety
	// Check if message exists
	// Delete from map
	// Return error if message not found
	ms.Mutex.Lock()         // Lock for all operations
	defer ms.Mutex.Unlock() // To unclock the thread when getting out of the function

	_, found := ms.Messages[id]
	if !found { // Failed to find the message
		return ErrMessageNotFound
	}

	// Delete the entry
	delete(ms.Messages, id)

	return nil // OK - no error
}

// Count returns the total number of messages
func (ms *MemoryStorage) Count() int {
	return len(ms.Messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
