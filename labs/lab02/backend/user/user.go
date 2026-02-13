package user

import (
	"context"
	"errors"
	"regexp"
	"sync"
)

var (
	ErrUserNotFound = errors.New("user not found")
	ErrEmptyName = errors.New("user name cannot be empty")
	ErrInvalidEmail = errors.New("invalid user email format")
	ErrEmptyId = errors.New("user id cannot be empty")
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
		return ErrEmptyName
	}
	if  !regexp.MustCompile(`^[^@]+@[^@]+\.[^@]+$`).MatchString(u.Email) {
		return ErrInvalidEmail
	}
	if u.ID == "" {
		return ErrEmptyId
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
	return &UserManager{
		ctx:   context.Background(),
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

	if _, ok := m.users[id]; !ok {
		return ErrUserNotFound
	}

	delete(m.users, id)

	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	
	user, ok := m.users[id]
	if !ok {
		return User{}, ErrUserNotFound
	}
	
	return user, nil
}
