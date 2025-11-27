package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
	"time"
)

// MemoryStorage implements in-memory storage for messages
type MemoryStorage struct {
	mu       sync.RWMutex
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

// GetAllMessages returns all messages
func (ms *MemoryStorage) GetAllMessages() []*models.Message {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	result := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		result = append(result, msg)
	}
	return result
}

// CreateMessage adds a new message to storage
func (ms *MemoryStorage) CreateMessage(username, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	id := ms.nextID
	msg := models.NewMessage(id, username, content)
	ms.messages[id] = msg
	ms.nextID++

	return msg, nil
}

// UpdateMessage modifies an existing message, updating content and timestamp
func (ms *MemoryStorage) UpdateMessage(id int, content string) (*models.Message, error) {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	msg.Content = content
	msg.Timestamp = time.Now()
	return msg, nil
}

// DeleteMessage removes a message from storage
func (ms *MemoryStorage) DeleteMessage(id int) error {
	ms.mu.Lock()
	defer ms.mu.Unlock()

	if _, ok := ms.messages[id]; !ok {
		return ErrMessageNotFound
	}
	delete(ms.messages, id)
	return nil
}

// CountMessages returns the total number of messages
func (ms *MemoryStorage) CountMessages() int {
	ms.mu.RLock()
	defer ms.mu.RUnlock()
	return len(ms.messages)
}

// Common errors
var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)

func (ms *MemoryStorage) GetAll() []*models.Message {
	return ms.GetAllMessages()
}

func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	return ms.CreateMessage(username, content)
}

func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	return ms.UpdateMessage(id, content)
}

func (ms *MemoryStorage) Delete(id int) error {
	return ms.DeleteMessage(id)
}

func (ms *MemoryStorage) Count() int {
	return ms.CountMessages()
}

func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mu.RLock()
	defer ms.mu.RUnlock()

	msg, ok := ms.messages[id]
	if !ok {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}
