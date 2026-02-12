package storage

import (
	"errors"
	"lab03-backend/models"
	"sync"
)

type MemoryStorage struct {
	mu       sync.RWMutex
	messages map[int]models.Message
	nextID   int
}

func NewMemoryStorage() *MemoryStorage {
	return &MemoryStorage{
		messages: make(map[int]models.Message),
		nextID:   1,
	}
}

func (s *MemoryStorage) Create(username, content string) (*models.Message, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	message := models.Message{
		ID:       s.nextID,
		Username: username,
		Content:  content,
	}

	s.messages[s.nextID] = message
	s.nextID++

	return &message, nil
}

func (s *MemoryStorage) GetByID(id int) (*models.Message, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	message, exists := s.messages[id]
	if !exists {
		return nil, errors.New("message not found")
	}
	return &message, nil
}

func (s *MemoryStorage) GetAll() []models.Message {
	s.mu.RLock()
	defer s.mu.RUnlock()

	messages := make([]models.Message, 0, len(s.messages))
	for _, msg := range s.messages {
		messages = append(messages, msg)
	}
	return messages
}

func (s *MemoryStorage) Update(id int, content string) (*models.Message, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	message, exists := s.messages[id]
	if !exists {
		return nil, errors.New("message not found")
	}

	message.Content = content
	s.messages[id] = message
	return &message, nil
}

func (s *MemoryStorage) Delete(id int) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	_, exists := s.messages[id]
	if !exists {
		return errors.New("message not found")
	}

	delete(s.messages, id)
	return nil
}

func (s *MemoryStorage) Count() int {
	s.mu.RLock()
	defer s.mu.RUnlock()

	return len(s.messages)
}
