package userdomain

import (
	"errors"
	"regexp"
	_ "regexp"
	"strings"
	"time"
)

// User represents a user entity in the domain
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Password  string    `json:"-"` // Never serialize password
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// NewUser creates a new user with validation
func NewUser(email, name, password string) (*User, error) {
	u := User{
		Email:     email,
		Name:      name,
		Password:  password,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := u.Validate(); err != nil {
		return nil, err
	}
	return &u, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	if ValidateEmail(u.Email) != nil || ValidateName(u.Name) != nil || ValidatePassword(u.Password) != nil {
		//wrong errors handling
		return errors.New("some error occured...")
	}
	return nil
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	trimmedEmail := strings.TrimSpace(email)
	emaiLC := strings.ToLower(trimmedEmail)
	re := regexp.MustCompile(`(?i)^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$`)
	if !re.MatchString(emaiLC) {
		return errors.New("invalid email")
	}
	return nil
}

// ValidateName checks if name is valid
func ValidateName(name string) error {

	//3rd shitty validation
	spaceChecker := false
	for _, c := range name {
		if c != ' ' {
			spaceChecker = true
		}
	}
	if spaceChecker == false {
		return errors.New("contains only spaces")
	}

	strings.TrimSpace(name)
	if 50 < len(name) || len(name) < 2 {
		return errors.New("name is too short or empty")
	}
	return nil
}

// ValidatePassword checks if password meets security requirements
func ValidatePassword(password string) error {

	if len(password) < 8 {
		return errors.New("Password is too short")
	}

	//another shitty validation
	allowedLC := "abcdefghijklmnopqrstuvwxyz"
	allowedUC := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	numbers := "0123456789"
	LC, UC, Num := false, false, false

	for _, c := range password {
		switch {
		case strings.ContainsRune(allowedLC, c) == true:
			LC = true
		case strings.ContainsRune(allowedUC, c) == true:
			UC = true
		case strings.ContainsRune(numbers, c) == true:
			Num = true
		}
	}

	if LC && UC && Num {
		return nil
	}

	return errors.New("password is too simple")
}

// UpdateName updates the user's name with validation
func (u *User) UpdateName(name string) error {
	if err := ValidateName(name); err != nil {
		return err
	}
	u.Name = strings.TrimSpace(name)
	u.UpdatedAt = time.Now()
	return nil
}

// UpdateEmail updates the user's email with validation
func (u *User) UpdateEmail(email string) error {
	if err := ValidateEmail(email); err != nil {
		return err
	}
	u.Email = strings.ToLower(strings.TrimSpace(email))
	u.UpdatedAt = time.Now()
	return nil
}
