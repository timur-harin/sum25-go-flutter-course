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

var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidEmail = errors.New("invalid email format")
	ErrInvalidID    = errors.New("invalid id: must be between 1 and 30 characters")
	ErrNoUserWithID = errors.New("no user with given id")
)

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	validEmail := regexp.MustCompile(`^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,4}$`)
	return validEmail.MatchString(email)
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	return (len(name) < 30) && (len(name) > 0)
}

// IsValidID checks if id is valid, returns false if the id is empty or longer than 30 characters
func IsValidID(id string) bool {
	return (len(id) > 0) && (len(id) < 30)
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidName(u.Name) {
		return ErrInvalidName
	}

	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	if !IsValidID(u.ID) {
		return ErrInvalidID
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
	if err := m.inContext(); err != nil {
		return err
	}
	err := u.Validate()
	if err != nil {
		return err
	}
	m.mutex.Lock()
	defer m.mutex.Unlock()
	m.users[u.ID] = u
	return nil
}

// Checks if context is existed and not done
func (m *UserManager) inContext() error {
	if m.ctx == nil {
		return nil
	}
	select {
	case <-m.ctx.Done():
		return m.ctx.Err()
	default:
		return nil
	}
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	_, exists := m.users[id]
	if !exists {
		return ErrNoUserWithID
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	usr, exists := m.users[id]
	if !exists {
		return usr, ErrNoUserWithID
	}
	return usr, nil
}
