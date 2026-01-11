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
	if u.ID == "" {
		return errors.New("user ID cannot be empty")
	}
	if u.Name == "" {
		return errors.New("user name cannot be empty")
	}
	emailRegex := `^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`
	matched, _ := regexp.MatchString(emailRegex, u.Email)
	if !matched {
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
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return errors.New("operation cancelled")
		default:
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

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, exists := m.users[id]; !exists {
		return errors.New("user does not exist")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	if user, exists := m.users[id]; exists {
		return user, nil
	}
	return User{}, errors.New("not found")
}
