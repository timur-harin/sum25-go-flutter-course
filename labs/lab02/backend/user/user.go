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

func IsValidEmail(email string) bool {
	var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// TODO: Validate name, email, id
	if u.Name == "" {
		return errors.New("empty name")
	} else if u.Email == "" {
		return errors.New("empty email")
	} else if !IsValidEmail(u.Email) {
		return errors.New("invalid email")
	} else if u.ID == "" {
		return errors.New("empty id")
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
	// TODO: Add user to map, check context
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		default:
		}
	}

	m.users[u.ID] = u

	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, ok := m.users[id]; !ok {
		return errors.New("no user with such id")
	}

	delete(m.users, id)

	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if user, ok := m.users[id]; ok {
		return user, nil
	}

	return User{}, errors.New("not found")
}
