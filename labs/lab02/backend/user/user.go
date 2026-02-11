package user

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
	"reflect"
	"strings"
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
	if !IsValidName(u.Name) {
		return fmt.Errorf("ErrInvalidEmail")
	}

	if u.ID == "" {
		return fmt.Errorf("invalid ID")
	}

	if !IsValidEmail(u.Email) {
		return fmt.Errorf("ErrInvalidEmail")
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
	if m.ctx != nil {
		select {
		case <- m.ctx.Done():
				return m.ctx.Err()
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

	delete(m.users, id)

	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()

	user := m.users[id]

	if reflect.DeepEqual(user, User{}) {
		return User{}, errors.New("not found")
	}

	return user, nil
}


func IsValidName(name string) bool {
	if name == "" || len(name) > 30 {
		return false
	}
	return true
}


func IsValidEmail(email string) bool {
	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return false
	}

	if !strings.Contains(parts[1], ".") {
		return false
	}

	if _, err := mail.ParseAddress(email); err != nil {
		return false
	}
	return true
}