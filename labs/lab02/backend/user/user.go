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
	ErrInvalidID    = errors.New("invalid id")
	ErrInvalidName  = errors.New("invalid name")
	ErrInvalidEmail = errors.New("invalid email format")
)

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidName(u.Name) {
		return ErrInvalidName
	}
	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}
	if !IsValidId(u.ID) {
		return ErrInvalidID
	}
	return nil
}

func IsValidEmail(email string) bool {
	isValid, err := regexp.MatchString("(^$|^.*@.*\\..*$)", email)
	if err != nil {
		return false
	}
	return isValid
}

// IsValidName checks if the name is valid, returns false if the name is empty
func IsValidName(name string) bool {
	return name != ""
}

// IsValidId checks if the name is valid, returns false if the name is empty
func IsValidId(id string) bool {
	return id != ""
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
	if m.ctx != nil {
		select {
		case <-m.ctx.Done():
			return errors.New("context is cancelled")
		}
	}
	err := u.Validate()
	if err != nil {
		return err
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	if user, ok := m.users[id]; ok {
		return user, nil
	}
	return User{}, errors.New("not found")
}
