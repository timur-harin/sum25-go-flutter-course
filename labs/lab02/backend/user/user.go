package user

import (
	"context"
	"errors"
	"sync"
	"regexp"
)

// User represents a chat user

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
	re := regexp.MustCompile(`^[^@]+@[^@]+\.[^@]+$`)
	if !re.MatchString(u.Email) {
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
}

// NewUserManager creates a new UserManager
func NewUserManager() *UserManager {
	return &UserManager{
		ctx:   context.Background(),
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

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	if m.ctx != nil {
		if err := m.ctx.Err(); err != nil {
			return err
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
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, exists := m.users[id]; !exists {
		return errors.New("not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	u, exists := m.users[id]
	if !exists {
		return User{}, errors.New("not found")
	}
	return u, nil
}
