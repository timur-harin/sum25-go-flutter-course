package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

var (
	ErrInvalidName  = errors.New("empty name")
	ErrInvalidEmail = errors.New("invalid email")
	ErrInvalidId    = errors.New("empty id")
	ErrNotFound     = errors.New("not found")
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
		return ErrInvalidName
	}

	if u.Email == "" || !strings.Contains(u.Email, "@") {
		return ErrInvalidEmail
	}

	if u.ID == "" {
		return ErrInvalidId
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
	if err := u.Validate(); err != nil {
		return err
	}

	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:
		}
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
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:
		}
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, ok := m.users[id]; !ok {
		return ErrNotFound
	}

	delete(m.users, id)

	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return User{}, m.ctx.Err()
		default:
		}
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	user, ok := m.users[id]
	if !ok {
		return User{}, ErrNotFound
	}

	return user, nil
}
