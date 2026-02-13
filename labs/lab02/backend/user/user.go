package user

import (
	"context"
	"errors"
	"sync"
	"regexp"
)

// User represents a chat user
type User struct {
	Name  string
	Email string
	ID    string
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if u.Name == "" {
		return errors.New("name cannot be empty")
	}

	if len(u.Name) > 100 {
		return errors.New("name too long")
	}

	if u.Email == "" {
		return errors.New("email cannot be empty")
	}

	if len(u.Email) > 255 {
		return errors.New("email too long")
	}

	emailRegex := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	if !regexp.MustCompile(emailRegex).MatchString(u.Email) {
		return errors.New("invalid email format")
	}

	if u.ID == "" {
		return errors.New("ID cannot be empty")
	}

	return nil
}

// UserManager manages users
type UserManager struct {
	ctx   context.Context
	users map[string]User
	mutex sync.RWMutex
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
		ctx:   ctx,
		users: make(map[string]User),
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	if err := m.ctx.Err(); err != nil {
		return err
	}

	if err := u.Validate(); err != nil {
		return err
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if err := m.ctx.Err(); err != nil {
		return err
	}

	if _, exists := m.users[u.ID]; exists {
		return errors.New("user already exists")
	}

	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	if err := m.ctx.Err(); err != nil {
		return err
	}

	if id == "" {
		return errors.New("user ID cannot be empty")
	}

	m.mutex.Lock()
	defer m.mutex.Unlock()

	if err := m.ctx.Err(); err != nil {
		return err
	}

	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	if err := m.ctx.Err(); err != nil {
		return User{}, err
	}

	if id == "" {
		return User{}, errors.New("user ID cannot be empty")
	}

	m.mutex.RLock()
	defer m.mutex.RUnlock()

	if err := m.ctx.Err(); err != nil {
		return User{}, err
	}

	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}

	return user, nil
}