package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

// User представляет пользователя
type User struct {
	Name  string
	Email string
	ID    string
}

// Validate проверяет валидность данных пользователя
func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("id cannot be empty")
	}
	// Простая проверка email на наличие '@'
	if !strings.Contains(u.Email, "@") {
		return errors.New("invalid email")
	}
	return nil
}

// UserManager управляет пользователями
type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
}

// NewUserManager создает менеджер без контекста
func NewUserManager() *UserManager {
	return &UserManager{
		users: make(map[string]User),
	}
}

// NewUserManagerWithContext создает менеджер с контекстом
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser добавляет пользователя, учитывает отмену контекста
func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return errors.New("context canceled")
		default:
		}
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	m.users[u.ID] = u
	return nil
}

// RemoveUser удаляет пользователя по ID
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, ok := m.users[id]; !ok {
		return errors.New("user not found")
	}

	delete(m.users, id)
	return nil
}

// GetUser возвращает пользователя по ID или ошибку
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	u, ok := m.users[id]
	if !ok {
		return User{}, errors.New("not found")
	}
	return u, nil
}
