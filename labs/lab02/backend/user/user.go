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
	if u.ID == "" {
		return errors.New("user ID cannot be empty")
	}
	if u.Name == "" {
		return errors.New("user name cannot be empty")
	}
	if u.Email == "" {
		return errors.New("user email cannot be empty")
	}
	at := strings.Index(u.Email, "@")
	dot := strings.LastIndex(u.Email, ".")
	if at < 1 || dot < at+2 || dot == len(u.Email)-1 {
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
	return &UserManager{users: make(map[string]User)}
}

func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{ctx: ctx, users: make(map[string]User)}
}

var ErrUserExists = errors.New("user already exists")
var ErrUserNotFound = errors.New("user not found")

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
		return ErrUserExists
	}
	m.users[u.ID] = u
	return nil
}

func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, exists := m.users[id]; !exists {
		return ErrUserNotFound
	}
	delete(m.users, id)
	return nil
}

func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	if u, exists := m.users[id]; exists {
		return u, nil
	}
	return User{}, ErrUserNotFound
}
