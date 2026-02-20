package user

import (
	"context"
	"errors"
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
	if len(u.Name) == 0 {
		return errors.New("Empty name")
	}
	check := regexp.MustCompile(`^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$`)
	if !check.Match([]byte(u.Email)) {
		return errors.New("Invalid email")
	}
	if len(u.ID) == 0 {
		return errors.New("Empty Id")
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
	if m.ctx != nil && m.ctx.Err() != nil {
		return m.ctx.Err()
	}
	err := u.Validate()
	if err != nil {
		return err
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	_, ok := m.users[u.ID]
	if ok {
		return errors.New("user already exist")
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	m.mutex.Lock()
	defer m.mutex.Unlock()
	_, ok := m.users[id]
	if !ok {
		return errors.New("user dont exist")
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
