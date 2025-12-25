package userdomain

import (
	"errors"
	"regexp"
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

func NewUser(email, name, password string) (*User, error) {
	user := &User{Email: email, Name: name, Password: password, CreatedAt: time.Now(), UpdatedAt: time.Now()}
	if err := user.Validate(); err != nil {
		return nil, err
	}
	return user, nil
}

func (u *User) Validate() error {
	if err := ValidateEmail(u.Email); err != nil {
		return err
	}
	if err := ValidateName(u.Name); err != nil {
		return err
	}
	if err := ValidatePassword(u.Password); err != nil {
		return err
	}
	return nil
}

func ValidateEmail(email string) error {
	email = strings.TrimSpace(email)
	email = strings.ToLower(email)
	if email == "" {
		return errors.New("invalid email")
	}
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(email) {
		return errors.New("invalid email")
	}
	return nil
}

func ValidateName(name string) error {
	name = strings.TrimSpace(name)
	if len(name) < 2 || len(name) > 50 {
		return errors.New("invalid name")
	}
	if name == "" {
		return errors.New("invalid name")
	}
	return nil
}

func ValidatePassword(password string) error {
	lowercaseLetters := []rune{}

	for symbol := 'a'; symbol <= 'z'; symbol++ {
		lowercaseLetters = append(lowercaseLetters, symbol)
	}

	uppercaseLetters := []rune{}

	for symbol := 'A'; symbol <= 'Z'; symbol++ {
		uppercaseLetters = append(uppercaseLetters, symbol)
	}

	if len(password) < 8 {
		return errors.New("invalid password")
	}

	hasLowercaseLetter := false

	for i := 0; i < len(password); i++ {
		for j := 0; j < len(lowercaseLetters); j++ {
			if byte(password[i]) == byte(lowercaseLetters[j]) {
				hasLowercaseLetter = true
				break
			}
		}
		if hasLowercaseLetter {
			break
		}
	}

	if !hasLowercaseLetter {
		return errors.New("invalid password")
	}

	hasUppercaseLetter := false

	for i := 0; i < len(password); i++ {
		for j := 0; j < len(uppercaseLetters); j++ {
			if byte(password[i]) == byte(uppercaseLetters[j]) {
				hasUppercaseLetter = true
				break
			}
		}
		if hasUppercaseLetter {
			break
		}
	}

	if !hasUppercaseLetter {
		return errors.New("invalid password")
	}

	digits := []int{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}

	hasDigit := false

	for i := 0; i < len(password); i++ {
		for j := 0; j < len(digits); j++ {
			if byte(password[i]) == byte(digits[j]) {
				hasDigit = true
				break
			}
		}
		if hasDigit {
			break
		}
	}

	if !hasDigit {
		return errors.New("invalid password")
	}

	return nil
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
