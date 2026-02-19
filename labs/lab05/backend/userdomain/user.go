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

// NewUser creates a new user with validation
func NewUser(email, name, password string) (*User, error) {
	// Create a user with the provided data
	res := &User{Email: email, Name: name, Password: password}

	// Validate the user
	err := res.Validate()
	if err != nil {
		return nil, err
	}

	// Set the current timestamp
	now := time.Now()
	res.CreatedAt = now
	res.UpdatedAt = now

	// OK, return a pointer to the created user
	return res, nil
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// Check the name
	nameErr := ValidateName(u.Name)
	// Check the email
	emailErr := ValidateEmail(u.Email)
	// Check the password
	pwdErr := ValidatePassword(u.Password)

	if nameErr != nil || emailErr != nil || pwdErr != nil {
		return errors.New("invalid user data")
	}

	// OK, user info is valid
	return nil
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) error {
	// To pass the tests
	email = strings.TrimSpace(email)
	email = strings.ToLower(email)

	// Check if the email is empty
	if email == "" {
		return errors.New("empty email provided: ValidateEmail()")
	}

	// Check for email format being correct
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if !emailRegex.MatchString(email) {
		return errors.New("invalid email format: ValidateEmail()")
	}

	// OK, no error
	return nil
}

// ValidateName checks if name is valid
func ValidateName(name string) error {
	// Trim the spaces
	name = strings.TrimSpace(name)

	// Check the length
	const minNameLength = 2
	const maxNameLength = 50
	if len(name) < minNameLength || len(name) > maxNameLength {
		return errors.New("invalid name length")
	}

	// OK, no error
	return nil
}

// ValidatePassword checks if password meets security requirements
// Author: Magomedgadzhi Ibragimov
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
