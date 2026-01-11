package user

import (
	"context"
	"errors"
	"fmt"
	"regexp"
	"sync"
)

// User represents a chat user
type User struct {
	Name  string
	Email string
	ID    string
}

// A simple regex for email validation
var emailRegex = regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`)

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.ID == "" {
		return errors.New("user ID cannot be empty")
	}
	if u.Name == "" {
		return errors.New("user name cannot be empty")
	}
	if !emailRegex.MatchString(u.Email) {
		return fmt.Errorf("invalid email format for user %s: %s", u.Name, u.Email)
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context
type UserManager struct {
	ctx   context.Context
	users map[string]User // userID -> User
	mutex sync.RWMutex    // Protects users map
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	// By default, use a background context that is never cancelled.
	return NewUserManagerWithContext(context.Background())
}

// NewUserManagerWithContext creates a new UserManager with a specific context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser adds a user to the manager
func (m *UserManager) AddUser(u User) error {
	// Check if the manager's context has been cancelled.
	select {
	case <-m.ctx.Done():
		return m.ctx.Err()
	default:
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[u.ID]; exists {
		return fmt.Errorf("user with ID '%s' already exists", u.ID)
	}

	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user from the manager
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return fmt.Errorf("user with ID '%s' not found", id)
	}

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by their ID
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, ok := m.users[id]
	if !ok {
		return User{}, fmt.Errorf("user with ID '%s' not found", id)
	}
	return user, nil
}
