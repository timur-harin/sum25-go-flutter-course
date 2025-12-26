package user

import (
	"context"
	"errors"
	"fmt"
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
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("user name cannot be empty")
	}
	if strings.TrimSpace(u.ID) == "" {
		return errors.New("user ID cannot be empty")
	}
	if !strings.Contains(u.Email, "@") || strings.TrimSpace(u.Email) == "" {
		return errors.New("user email is invalid")
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
	select {
	case <-m.ctx.Done():
		return m.ctx.Err() // Возвращаем ошибку отмены
	default:
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[u.ID]; exists {
		return fmt.Errorf("user with ID %s already exists", u.ID)
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	select {
	case <-m.ctx.Done():
		return m.ctx.Err()
	default:
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return fmt.Errorf("user with ID %s not found", id)
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	select {
	case <-m.ctx.Done():
		return User{}, m.ctx.Err()
	default:
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, ok := m.users[id]
	if !ok {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
