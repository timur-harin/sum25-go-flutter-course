package user

import (
	"context"
	"errors"
	"regexp"
	"strconv"
	"sync"
)

// User represents a chat user
// TODO: Add more fields if needed

type User struct {
	Name  string
	Email string
	ID    string
	Age   int // возраст пользователя
}

func IsValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	match, _ := regexp.MatchString(pattern, email)
	return match
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	if len(name) < 1 || len(name) > 30 {
		return false
	}
	return true
}

// IsValidAge checks if the id is valid, returns false if the id is not below 0
func IsValidId(id int) bool {
	return id > 0 && id <= 150
}

func StringToInt(s string) (int, error) {
	i, err := strconv.Atoi(s)
	if err != nil {
		return 0, err
	}
	return i, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidName(u.Name) {
		return errors.New("name is not valid")
	}
	if !IsValidEmail(u.Email) {
		return errors.New("email is not valid")
	}
	if u.ID == "" {
		return errors.New("id is empty")
	}
	intid, err := StringToInt(u.ID)
	if err != nil {
		return errors.New("id is not valid")
	}
	if !IsValidId(intid) {
		return errors.New("id is not valid")
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
	m.mutex.Lock()
	defer m.mutex.Unlock()
	select {
	case <-m.ctx.Done():
		return errors.New("context canceled")
	default:
	}
	if _, exists := m.users[u.ID]; exists {
		return errors.New("user already exists")
	}
	m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	if _, exists := m.users[id]; !exists {
		return errors.New("user not found")
	}
	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.RLock()
	defer m.mutex.RUnlock()
	user, exists := m.users[id]
	if !exists {
		return User{}, errors.New("user not found")
	}
	return user, nil
}
