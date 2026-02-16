package user

import (
	"context"
	"errors"
	"regexp"
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
		return errors.New("name is empty")
	}
	if u.ID == "" {
		return errors.New("id is empty")
	}
	emailRegex := regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)
	if !emailRegex.MatchString(u.Email) {
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
		select {
		case <-m.ctx.Done():
			return errors.New("context canceled")
		default:
		}
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, ok := m.users[id]; !ok {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	u, ok := m.users[id]
	if !ok {
		return User{}, errors.New("not found")
	}
	return u, nil
}
