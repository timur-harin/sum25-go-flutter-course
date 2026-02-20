package user

import (
	"context"
	"errors"
	"fmt"
	"regexp"
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
	if u.ID == "" {
		return errors.New("user ID cannot be empty")
	}
	if u.Name == "" {
		return errors.New("user name cannot be empty")
	}
	re := regexp.MustCompile(`^[^\s@]+@[^\s@]+\.[^\s@]+$`)
	if !re.MatchString(u.Email) {
		return fmt.Errorf("invalid email format: %s", u.Email)
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

// AddUser adds a user
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
		return errors.New("user ID already exists")
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	u, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return u, nil
}
