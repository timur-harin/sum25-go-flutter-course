package user

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
	"strings"
	"sync"
)

// User represents a chat user.
type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid.
func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("ID cannot be empty")
	}
	if _, err := mail.ParseAddress(u.Email); err != nil {
		return fmt.Errorf("invalid email: %v", err)
	}
	return nil
}

// UserManager manages users.
type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
	mutex sync.RWMutex    // protects users map
}

// NewUserManager creates a new UserManager without context.
func NewUserManager() *UserManager {
	return &UserManager{
		ctx:   context.Background(),
		users: make(map[string]User),
	}
}

// NewUserManagerWithContext creates a new UserManager with context.
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser adds a user to the manager.
func (m *UserManager) AddUser(u User) error {
	// Validate user fields
	if err := u.Validate(); err != nil {
		return err
	}

	// Check if context is canceled
	select {
	case <-m.ctx.Done():
		return fmt.Errorf("context canceled: %v", m.ctx.Err())
	default:
	}

	// Lock for writing
	m.mutex.Lock()
	defer m.mutex.Unlock()

	// Add user
	if _, exists := m.users[u.ID]; exists {
		return errors.New("user already exists")
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user by ID.
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by ID.
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	u, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return u, nil
}
