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
		return errors.New("name can't be empty")
	} else if !strings.Contains(u.Email, "@") {
		return errors.New("the email has to contain @ character")
	} else if strings.TrimSpace(u.ID) == "" {
		return errors.New("id can't be empty")
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
	select {
	case <-m.ctx.Done():
		return errors.New("user manager is shut down")
	default:
	}
	if err := u.Validate(); err != nil {
		return err
	}
	m.mutex.Lock()
	if _, found := m.users[u.ID]; found {
		return errors.New("user id already exists")
	}
	m.users[u.ID] = u
	m.mutex.Unlock()
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	select {
	case <-m.ctx.Done():
		return errors.New("user manager is shut down")
	default:
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, found := m.users[id]; !found {
		return errors.New("user id does not exist")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	select {
	case <-m.ctx.Done():
		return User{}, errors.New("user manager is shut down")
	default:
	}
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	if user, found := m.users[id]; found {
		return user, nil
	}
	return User{}, errors.New("not found")
}
