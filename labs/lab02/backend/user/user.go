package user

import (
	"context"
	"errors"
	"fmt"
	"regexp"
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
	if u.Name == "" {
		return errors.New("invalid name: name cannot be empty")
	}

	if u.ID == "" {
		return errors.New("invalid ID: ID cannot be empty")
	}

	emailRegexp := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegexp.MatchString(u.Email) {
		return errors.New("invalid email format")
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
		users: make(map[string]User),
		mutex: sync.RWMutex{},
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	// TODO: Initialize UserManager with context
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
		mutex: sync.RWMutex{},
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	// TODO: Add user to map, check context
	if m.ctx != nil {
		err := m.ctx.Err()
		if err != nil {
			return fmt.Errorf("operation cancelled: %w", err)
		}
	}

	err := u.Validate()
	if err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	if m.ctx != nil {
		err := m.ctx.Err()
		if err != nil {
			return fmt.Errorf("operation cancelled: %w", err)
		}
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	_, exists := m.users[id]
	if !exists {
		return errors.New("user not found")
	}

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	if m.ctx != nil {
		err := m.ctx.Err()
		if err != nil {
			return User{}, fmt.Errorf("operation cancelled: %w", err)
		}
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
