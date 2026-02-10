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
	if u.Email == "" || !strings.Contains(u.Email, "@") {
		return errors.New("invalid email format")
	}
	if u.ID == "" {
		return errors.New("ID cannot be empty")
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
	}
}

func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:
		}
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[u.ID]; exists {
		return errors.New("user already exists")
	}

	m.users[u.ID] = u
	return nil
}

func (m *UserManager) RemoveUser(id string) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:
		}
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}

	delete(m.users, id)
	return nil
}

func (m *UserManager) GetUser(id string) (User, error) {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return User{}, m.ctx.Err()
		default:
		}
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	if user, exists := m.users[id]; exists {
		return user, nil
	}
	return User{}, errors.New("user not found")
}
