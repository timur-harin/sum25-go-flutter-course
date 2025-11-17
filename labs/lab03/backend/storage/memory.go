package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

type MemoryStorage struct {
	mutex    sync.RWMutex
	messages map[int]*models.Message
	nextID   int
}

func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		messages: make(map[int]*models.Message),
		nextID:   1,
	}
}

func (ms *MemoryStorage) GetAll() []*models.Message {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	result := make([]*models.Message, 0, len(ms.messages))
	for _, msg := range ms.messages {
		result = append(result, msg)
	}
	return result
}

func (ms *MemoryStorage) GetByID(id int) (*models.Message, error) {
	ms.mutex.RLock()
	defer ms.mutex.RUnlock()

	if id <= 0 {
		return nil, ErrInvalidID
	}

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}
	return msg, nil
}

func (ms *MemoryStorage) Create(username, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if username == "" || content == "" {
		return nil, errors.New("username and content are required")
	}

	message := models.NewMessage(ms.nextID, username, content)
	ms.messages[ms.nextID] = message
	ms.nextID++
	return message, nil
}

func (ms *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if id <= 0 {
		return nil, ErrInvalidID
	}

	if content == "" {
		return nil, errors.New("content is required")
	}

	msg, exists := ms.messages[id]
	if !exists {
		return nil, ErrMessageNotFound
	}

	msg.Content = content
	return msg, nil
}

// Delete removes a message from storage
func (ms *MemoryStorage) Delete(id int) error {
	ms.mutex.Lock()
	defer ms.mutex.Unlock()

	if id <= 0 {
		return ErrInvalidID
	}

	if _, exists := ms.messages[id]; !exists {
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

var (
	ErrMessageNotFound = errors.New("message not found")
	ErrInvalidID       = errors.New("invalid message ID")
)
