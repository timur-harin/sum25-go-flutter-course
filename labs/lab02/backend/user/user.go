package user

import (
	"context"
	"errors"
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
		return errors.New("user ID is required")
	}
	if u.Name == "" {
		return errors.New("user name is required")
	}
	if u.Email == "" {
		return errors.New("user email is required")
	}
	// Very basic email validation
	match, _ := regexp.MatchString(`^[^@\s]+@[^@\s]+\.[^@\s]+$`, u.Email)
	if !match {
		return errors.New("invalid email format")
	}
	return nil
}

// UserManager manages users in a thread-safe way
type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
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

// AddUser adds a new user if it passes validation and doesn't already exist
func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return errors.New("context cancelled")
		default:
			// continue
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

// RemoveUser deletes a user by ID
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by ID
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
