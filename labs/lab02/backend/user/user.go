package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

// User represents a chat user

type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	name := u.Name
	email := u.Email
	id := u.ID
	if name == "" {
		return errors.New("empty name")
	}
	if !strings.Contains(email, "@") || !strings.Contains(email, ".") {
		return errors.New("invalid email")
	}
	if id == "" {
		return errors.New("empty id")
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context

type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
	mutex sync.RWMutex    // Protects users map
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	return &UserManager{
		users: make(map[string]User),
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	if m.ctx == nil {
		m.ctx = context.Background()
	}
	select {
	case <-m.ctx.Done():
		return m.ctx.Err()
	default:
		m.mutex.Lock()
		m.users[u.ID] = u
		m.mutex.Unlock()
		return nil
	}
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	_, ok := m.users[id]
	m.mutex.Unlock()
	if !ok {
		return errors.New("not found")
	}
	m.mutex.Lock()
	delete(m.users, id)
	m.mutex.Unlock()
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.Lock()
	user, ok := m.users[id]
	m.mutex.Unlock()
	if !ok {
		return User{}, errors.New("not found")
	}
	return user, nil
}
