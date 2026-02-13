package user

import (
	"context"
	"errors"
	"regexp"
	"sync"
)

// User represents a chat user.
type User struct {
	Name  string
	Email string
	ID    string
}

var emailRegex = regexp.MustCompile(
	`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`,
)

// Validate checks that Name, Email, and ID are non‐empty and Email is well‐formed.
func (u *User) Validate() error {
	if u.Name == "" {
		return errors.New("name cannot be empty")
	}
	if u.Email == "" {
		return errors.New("email cannot be empty")
	}
	if !emailRegex.MatchString(u.Email) {
		return errors.New("invalid email format")
	}
	if u.ID == "" {
		return errors.New("id cannot be empty")
	}
	return nil
}

// UserManager manages a set of Users with concurrent safety.
type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
}

// NewUserManager creates a manager without request context.
func NewUserManager() *UserManager {
	return &UserManager{
		users: make(map[string]User),
	}
}

// NewUserManagerWithContext creates a manager that observes ctx cancellation.
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser validates and adds a new user, returning context error if canceled.
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
		return errors.New("user already exists")
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser deletes a user by ID.
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
	if u, exists := m.users[id]; exists {
		return u, nil
	}
	return User{}, errors.New("user not found")
}
