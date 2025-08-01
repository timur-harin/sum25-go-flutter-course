package user

import (
	"context"
	"errors"
	"net/mail"
	"sync"
)

// User represents a chat user
type User struct {
	Name  string
	Email string
	ID    string
}

// Predefined errors
var (
	ErrInvalidName  = errors.New("invalid name")
	ErrInvalidEmail = errors.New("invalid email format")
	ErrInvalidId    = errors.New("empty id")
	ErrUserExists   = errors.New("user already exists")
	ErrUserNotFound = errors.New("user not found")
	ErrContextDone  = errors.New("context is done")
)

// Validate checks if the user data is valid, returns an error for each invalid field
func (u *User) Validate() error {
	if !isValidName(u.Name) {
		return ErrInvalidName
	}

	if !isValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	if !isValidID(u.ID) {
		return ErrInvalidId
	}

	return nil
}

// isValidName checks if the name is valid, returns `false` if the name is empty or longer than 30 characters
func isValidName(name string) bool {
	lenName := len(name)
	return 1 <= lenName && lenName <= 30
}

// isValidEmail checks if the email format is valid
func isValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

// isValidID checks if the user ID is valid, returns `false` if an ID is empty
func isValidID(id string) bool {
	return len(id) != 0
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
		ctx:   context.Background(),
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		users: make(map[string]User),
		ctx:   ctx,
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	if m.ctx.Err() != nil {
		return ErrContextDone
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, ok := m.users[u.ID]; ok {
		return ErrUserExists
	}
	m.users[u.ID] = u

	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
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

	u, ok := m.users[id]
	if !ok {
		return User{}, ErrUserNotFound
	}

	return u, nil
}
