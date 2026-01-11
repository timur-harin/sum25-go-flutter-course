package user

import (
	"context"
	"errors"
	"strings"
	"sync"
)

var (
	ErrInvalidName  = errors.New("invalid name")
	ErrInvalidId    = errors.New("invalid id")
	ErrInvalidEmail = errors.New("invalid email")
	ErrUserNotFound = errors.New("not found")
)

// User represents a chat user

type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}
	if !IsValidId(u.ID) {
		return ErrInvalidId
	}
	if !IsValidName(u.Name) {
		return ErrInvalidName
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
	err := u.Validate()
	if err != nil {
		return err
	}
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:

		}
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
	_, ok := m.users[id]
	if !ok {
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
	if ok {
		return user, nil
	}
	return User{}, ErrUserNotFound
}

func IsValidEmail(email string) bool {
	if strings.Contains(email, "@") {
		domen := strings.Split(email, "@")[1]
		if strings.Contains(domen, ".") {
			return true
		}
	}
	return false
}

func IsValidName(name string) bool {
	if len(strings.TrimSpace(name)) < 1 {
		return false
	}
	return true
}

func IsValidId(id string) bool {
	return len(id) > 0
}
