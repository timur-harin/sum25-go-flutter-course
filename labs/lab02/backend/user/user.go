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
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("user ID cannot be empty")
	}
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("user name cannot be empty")
	}
	if strings.TrimSpace(u.Email) == "" {
		return errors.New("user email cannot be empty")
	}
	if !strings.Contains(u.Email, "@") {
		return errors.New("invalid email format")
	}
	return nil
}

// UserManager manages users
type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	return &UserManager{
		ctx:   context.Background(),
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
	// Check context first
	select {
	case <-m.ctx.Done():
		return errors.New("operation canceled")
	default:
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

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// Check context first
	select {
	case <-m.ctx.Done():
		return errors.New("operation canceled")
	default:
	}

	if strings.TrimSpace(id) == "" {
		return errors.New("user ID cannot be empty")
	}

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
	// Check context first
	select {
	case <-m.ctx.Done():
		return User{}, errors.New("operation canceled")
	default:
	}

	if strings.TrimSpace(id) == "" {
		return User{}, errors.New("user ID cannot be empty")
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}

	return user, nil
}
