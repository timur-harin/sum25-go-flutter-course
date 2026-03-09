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
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name is empty")
	}
	if !strings.Contains(u.Email, "@") {
		return errors.New("invalid email")
	}
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("id is empty")
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
		ctx:   context.Background(),
		users: make(map[string]User),
	}
}

func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil && m.ctx.Err() != nil {
		return m.ctx.Err()
	}
	if err := u.Validate(); err != nil {
		return err
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.users[u.ID] = u
	return nil
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
	user, ok := m.users[id]
	if !ok {
		return User{}, errors.New("not found")
	}
	return user, nil
}
