package user

import (
	"context"
	"errors"
	"regexp"
	"sync"
)

// User represents a user in the system
type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user fields are valid
func (u *User) Validate() error {
	if u.ID == "" {
		return errors.New("user ID cannot be empty")
	}
	if u.Name == "" {
		return errors.New("user name cannot be empty")
	}
	if !isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// isValidEmail validates the email format using regex
func isValidEmail(email string) bool {
	// Simple regex for demonstration purposes
	re := regexp.MustCompile(`^[^@]+@[^@]+\.[^@]+$`)
	return re.MatchString(email)
}

// UserManager manages users in memory
type UserManager struct {
	mutex  sync.RWMutex
	users  map[string]User
	ctx    context.Context
	cancel context.CancelFunc
}

// NewUserManager creates a UserManager with background context
func NewUserManager() *UserManager {
	ctx, cancel := context.WithCancel(context.Background())
	return &UserManager{
		users:  make(map[string]User),
		ctx:    ctx,
		cancel: cancel,
	}
}

// NewUserManagerWithContext creates a UserManager with a given context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	// Provide a no-op cancel if not needed
	ctx, cancel := context.WithCancel(ctx)
	return &UserManager{
		users:  make(map[string]User),
		ctx:    ctx,
		cancel: cancel,
	}
}

// AddUser adds a user if context is not canceled and user is valid
func (m *UserManager) AddUser(user User) error {
	if err := user.Validate(); err != nil {
		return err
	}
	select {
	case <-m.ctx.Done():
		return errors.New("context canceled, cannot add user")
	default:
		m.mutex.Lock()
		defer m.mutex.Unlock()
		m.users[user.ID] = user
		return nil
	}
}

// GetUser retrieves a user by ID
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	user, ok := m.users[id]
	if !ok {
		return User{}, errors.New("user not found")
	}
	return user, nil
}

// RemoveUser removes a user by ID
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, ok := m.users[id]; !ok {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}
