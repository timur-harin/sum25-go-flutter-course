package user

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
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
	if u.Name == "" {
		return errors.New("name is required")
	}
	if u.ID == "" {
		return errors.New("id is required")
	}
	// Use net/mail to validate email format
	_, err := mail.ParseAddress(u.Email)
	if err != nil {
		return fmt.Errorf("invalid email: %w", err)
	}
	return nil
}

// UserManager manages users
type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
}

// NewUserManager creates a new UserManager without context
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

// AddUser adds a user to the manager
func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return errors.New("context cancelled")
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

// RemoveUser removes a user by ID
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, ok := m.users[id]; !ok {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by ID
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	u, ok := m.users[id]
	if !ok {
		return User{}, errors.New("user not found")
	}
	return u, nil
}
