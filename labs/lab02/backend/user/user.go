package user

import (
	"context"
	"errors"
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
	if u.Name == "" {
		return errors.New("name cannot be empty")
	}
	if u.ID == "" {
		return errors.New("id cannot be empty")
	}
	if u.Email == "" || !isValidEmail(u.Email) {
		return errors.New("invalid email")
	}
	return nil
}

func isValidEmail(email string) bool {
	return len(email) > 0 && containsAt(email) && containsDot(email)
}

func containsAt(s string) bool {
	for _, c := range s {
		if c == '@' {
			return true
		}
	}
	return false
}

func containsDot(s string) bool {
	for _, c := range s {
		if c == '.' {
			return true
		}
	}
	return false
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
	m.users[u.ID] = u
	m.mutex.Unlock()
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	delete(m.users, id)
	m.mutex.Unlock()
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	user, exists := m.users[id]
	m.mutex.RUnlock()
	if !exists {
		return User{}, errors.New("not found")
	}
	return user, nil
}
