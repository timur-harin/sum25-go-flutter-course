package user

import (
	"context"
	"errors"
	"regexp"
	"sync"
	"unicode/utf8"
)

// User represents a chat user
// TODO: Add more fields if needed
var (
	ErrInvalidName     = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidEmail    = errors.New("invalid email format")
	ErrInvalidIdSearch = errors.New("invalid id search")
	ErrInvalidId       = errors.New("invalid id: id cannot be empty")
)

type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Validate name, email, id
	regExp := regexp.MustCompile(`^[^@\s]+@[^@\s]+\.[^@\s]+$`)
	if utf8.RuneCountInString(u.Name) < 1 || utf8.RuneCountInString(u.Name) > 30 {
		return ErrInvalidName
	} else if !regExp.MatchString(u.Email) {
		return ErrInvalidEmail
	} else if u.ID == "" {
		return ErrInvalidId
	} else {
		return nil
	}
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
	// TODO: Add user to map, check context
	if u.Validate() != nil {
		return u.Validate()
	} else {
		if m.ctx.Err() != nil {
			return m.ctx.Err()
		}
		m.mutex.Lock()
		m.users[u.ID] = u
		m.mutex.Unlock()
		return nil
	}
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	if id == "" {
		return ErrInvalidId
	} else if m.ctx.Err() != nil {
		return m.ctx.Err()
	} else {
		m.mutex.Lock()
		_, ok := m.users[id]
		if ok {
			delete(m.users, id)
			m.mutex.Unlock()
		} else {
			m.mutex.Unlock()
			return ErrInvalidIdSearch
		}
	}
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	if id == "" {
		return User{}, ErrInvalidId
	} else if m.ctx.Err() != nil {
		return User{}, m.ctx.Err()
	} else {
		m.mutex.Lock()
		user, ok := m.users[id]
		if ok {
			m.mutex.Unlock()
			return user, nil
		} else {
			m.mutex.Unlock()
			return User{}, ErrInvalidIdSearch
		}
	}
}
