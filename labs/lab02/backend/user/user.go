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
	if u.Name == "" {
		return errors.New("User.Name is required")
	}
	if u.Email == "" {
		return errors.New("User.Email is required")
	}
	re := regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)
	if !re.MatchString(u.Email) {
		return errors.New("invalid email format")
	}
	if u.ID == "" {
		return errors.New("User.ID is required")
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
		ctx:   context.Background(),
		mutex: sync.RWMutex{},
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

	select {
	case <-m.ctx.Done():
		return errors.New("operation cancelled")
	default:
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.users[u.ID] = u

	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	if _, ok := m.users[id]; ok {
		delete(m.users, id)
	} else {
		return errors.New("user not found")
	}
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	if user, ok := m.users[id]; ok {
		return user, nil
	}
	return User{}, errors.New("not found")
}
