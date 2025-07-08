package user

import (
	"context"
	"errors"
	"regexp"
	"strconv"
	"sync"
)

// User represents a chat user
var (
	ErrInvalidName  = errors.New("invalid name: must be at least 1 character")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
	ErrUserAlreadyExist = errors.New("user with this ID already exist")
	ErrUserDoesNotExist = errors.New("user eith this ID does not exist")
	ErrContextCansel = errors.New("cotext cancel")
	emailRegexp = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
)

type User struct {
	Name  string
	Email string
	ID    string
}

func NewUser(name string, email string, id string) (User, error){
	user := User{
		Name: name,
		Email: email,
		ID: id,
	}
	err := user.Validate()
	if err != nil{
		return User{}, err
	}
	return user, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if !IsValidName(u.Name) {
		return ErrInvalidName
	}

	if !IsValidID(u.ID) {
		return ErrInvalidAge
	}

	if !IsValidEmail(u.Email) {
		return ErrInvalidEmail
	}

	return nil
}

func IsValidEmail(email string) bool {
	return emailRegexp.Match([]byte(email))
}

// IsValidName checks if the name is valid, returns false if the name is empty or longer than 30 characters
func IsValidName(name string) bool {
	return len(name) >= 1
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidID(ID string) bool {
	number, err := strconv.Atoi(ID)
	return err == nil && number > 0
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
		ctx: context.Background(),
		users: make(map[string]User),
		mutex: sync.RWMutex{},
	}
}

// NewUserManagerWithContext creates a new UserManager with context
func NewUserManagerWithContext(ctx context.Context) *UserManager {
	return &UserManager{
		ctx:   ctx,
		users: make(map[string]User),
		mutex: sync.RWMutex{},
	}
}

// AddUser adds a user
func (m *UserManager) AddUser(u User) error {
	if err := m.ctx.Err(); err != nil {
        return ErrContextCansel
    }
	m.mutex.Lock()
    defer m.mutex.Unlock()

    if _, exists := m.users[u.ID]; exists {
        return ErrUserAlreadyExist
    }

    m.users[u.ID] = u
	return nil
}

// RemoveUser removes a user
func (m *UserManager) RemoveUser(id string) error {
	m.mutex.Lock()
	defer m.mutex.Unlock()

	if _, exist := m.users[id]; !exist {
		return ErrUserDoesNotExist
	} 

	delete(m.users, id)
	return nil
}

// GetUser retrieves a user by id
func (m *UserManager) GetUser(id string) (User, error) {
	m.mutex.Lock()
	defer m.mutex.Unlock()
	user, exist := m.users[id]
	if !exist {
		return User{}, ErrUserDoesNotExist
	}
	return user, nil
}
