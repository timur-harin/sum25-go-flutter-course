package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

// User represents a chat user
// TODO: Add more fields if needed

type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Validate name, email, id
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name is required")
	}
	if !strings.Contains(u.Email, "@") {
		return errors.New("invalid email")
	}
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("id is required")
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context

type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
	mutex sync.RWMutex    // Protects users map
	// TODO: Add more fields if needed
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	// TODO: Initialize UserManager fields
	return &UserManager{
		ctx:   context.Background(),
		users: make(map[string]User),
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	// TODO: Initialize UserManager with context
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	// TODO: Add user to map, check context
	if err := u.Validate(); err != nil {
		return err
	}
	select {
	case <-m.ctx.Done():
		return errors.New("context canceled")
	default:
		m.mutex.Lock()
		defer m.mutex.Unlock()
		m.users[u.ID] = u
		return nil
	}
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, ok := m.users[id]; !ok {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	user, ok := m.users[id]
	if !ok {
		return User{}, errors.New("not found")
	}
	return user, nil
}
