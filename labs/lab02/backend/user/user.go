package user

import (
	"context"
	"errors"
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
	// TODO: Validate name, email, id
	if len(u.Name) == 0 {
		return errors.New("empty name")
	}

	// Very simple email checker
	var ret error = errors.New("invalid email")
	if len(u.Email) == 0 {
		return ret
	}

	atFound := false
	dotFound := false
	for _, ch := range u.Email {
		if ch == '@' {
			atFound = true
		}

		if ch == '.' {
			dotFound = true
		}
	}

	if !atFound || !dotFound { // Invalid email
		return ret
	}

	if len(u.ID) == 0 {
		return errors.New("empty ID")
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
	m.mutex.Lock()
	m.users[u.ID] = u
	m.mutex.Unlock()

	if m.ctx != nil {
		return m.ctx.Err()
	}

	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.RLock() // Lock for read operations
	_, found := m.users[id]
	m.mutex.RUnlock()

	if !found {
		return errors.New("not found")
	}

	// May not be the best solution
	m.mutex.Lock() // Lock for all operations
	delete(m.users, id)
	m.mutex.Unlock()

	return nil // Oll Korrect
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	user, found := m.users[id]
	m.mutex.RUnlock()

	if found { // OK
		return user, nil
	}

	return User{}, errors.New("not found")
}
