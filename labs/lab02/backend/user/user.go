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
	emailRegex := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	if u.Name == "" || len(u.Name) > 30 {
		return errors.New("Invalid name")
	}
	matched, err := regexp.MatchString(emailRegex, u.Email)
	if err != nil || !matched {
		return errors.New("Invalid email")
	}
	if u.ID == "" {
		return errors.New("Invalid Id")
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
	if err := u.Validate(); err != nil {
		return err
	}

	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		}
	} else {
		m.mutex.Lock()
		defer m.mutex.Unlock()
		m.users[u.ID] = u
	}
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return m.ctx.Err()
		}
	} else {
		m.mutex.RLock()
		user, ok := m.users[id]
		m.mutex.RUnlock()

		if !ok {
			return errors.New("User not found")
		}

		m.mutex.Lock()
		defer m.mutex.Unlock()
		delete(m.users, user.ID)
	}
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return User{}, m.ctx.Err()
		}
	} else {
		m.mutex.RLock()
		user, ok := m.users[id]
		m.mutex.RUnlock()

		if !ok {
			return User{}, errors.New("not found")
		}
		return user, nil
	}
}
