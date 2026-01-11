package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

type User struct {
	Name  string
	Email string
	ID    string
}

func (u *User) Validate() error {
	if u.Name == "" {
		return errors.New("name cannot be empty")
	}
	if u.ID == "" {
		return errors.New("ID cannot be empty")
	}
	if !strings.Contains(u.Email, "@") || !strings.Contains(u.Email, ".") {
		return errors.New("invalid email format")
	}
	return nil
}

type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
}

func NewUserManager() *UserManager {
	return &UserManager{
		users: make(map[string]User),
		ctx:   context.Background(),
	}
}

func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

func (m *UserManager) AddUser(u User) error {
	if err := u.Validate(); err != nil {
		return err
	}

	select {
	case <-m.ctx.Done():
		return errors.New("context canceled")
	default:
		m.mutex.Lock()
		defer m.mutex.Unlock()

		if _, exists := m.users[u.ID]; exists {
			return errors.New("user already exists")
		}
		m.users[u.ID] = u
		return nil
	}
}

func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
