package user

import (
	"context"
	"errors"
	"regexp"
	"sync"
)

var (
	ErrUserNotFound       = errors.New("user not found")
	ErrUserAlreadyExists  = errors.New("user with this ID already exists")
	ErrValidationFailed   = errors.New("validation failed")
	ErrNameEmpty          = errors.New("name cannot be empty")
	ErrIDEmpty            = errors.New("ID cannot be empty")
	ErrEmailEmpty         = errors.New("email cannot be empty")
	ErrInvalidEmailFormat = errors.New("invalid email format")
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
		return ErrNameEmpty
	}
	if u.ID == "" {
		return ErrIDEmpty
	}
	if u.Email == "" {
		return ErrEmailEmpty
	}
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(u.Email) {
		return ErrInvalidEmailFormat
	}
	return nil
}

// UserManager manages users
// Contains a map of users, a mutex, and a context
// TODO: Add more fields if needed

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

	if _, exists := m.users[u.ID]; exists {
		return ErrUserAlreadyExists
	}

	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	// TODO: Remove user from map
	select {
	case <-m.ctx.Done():
		return m.ctx.Err()
	default:
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exists := m.users[id]; !exists {
		return ErrUserNotFound
	}

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	// TODO: Get user from map
	select {
	case <-m.ctx.Done():
		return User{}, m.ctx.Err()
	default:
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user, ok := m.users[id]
	if !ok {
		return User{}, ErrUserNotFound
	}
	return user, nil
}
