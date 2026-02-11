package user

import (
	"context"
	"errors"
	"strings"
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
	if u.Name == "" {
		return errors.New("name cannot be empty")
	}
	if !strings.Contains(u.Email, "@") || !strings.Contains(u.Email, ".") {
		return errors.New("invalid email format")
	}
	if u.ID == "" {
		return errors.New("ID cannot be empty")
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context
type UserManager struct {
	ctx   context.Context // Contex to manage lifecycle
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
	// Checks if context is not cancelled
	if err := m.ctx.Err(); err != nil {
		return err
	}
	// Validation new user's data
	if err := u.Validate(); err != nil {
		return err
	}

	// Lock editing data
	m.mutex.Lock()
	// Allowing editing after exit the function
	defer m.mutex.Unlock()

	// Check if user already exists
	if _, exists := m.users[u.ID]; exists {
		return errors.New("user already exists")
	}

	// Adding new user
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// Lock editing data
	m.mutex.Lock()
	// Allowing editing after exit the function
	defer m.mutex.Unlock()

	// Check if user exists
	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}

	// Deleting user
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	// Finding user
	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}

	return user, nil
}
