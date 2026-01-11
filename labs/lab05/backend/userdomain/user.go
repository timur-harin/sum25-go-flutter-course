package userdomain

import (
	"errors"
	"regexp"
	"strings"
	"time"
)


type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	Password  string    `json:"-"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func NewUser(email, name, password string) (*User, error) {
	// Validate input parameters
	if validationError := ValidateEmail(email); validationError != nil {
		return nil, validationError
	}
	if validationError := ValidateName(name); validationError != nil {
		return nil, validationError
	}
	if validationError := ValidatePassword(password); validationError != nil {
		return nil, validationError
	}
	
	// Create timestamp for creation
	currentTime := time.Now()
	
	// Build new user instance
	newUser := &User{
		Email:     strings.ToLower(strings.TrimSpace(email)),
		Name:      strings.TrimSpace(name),
		Password:  password,
		CreatedAt: currentTime,
		UpdatedAt: currentTime,
	}
	
	return newUser, nil
}

func (u *User) Validate() error {
	// Validate email field
	if emailError := ValidateEmail(u.Email); emailError != nil {
		return emailError
	}
	
	// Validate name field
	if nameError := ValidateName(u.Name); nameError != nil {
		return nameError
	}
	
	// Validate password field
	if passwordError := ValidatePassword(u.Password); passwordError != nil {
		return passwordError
	}
	
	return nil
}

func ValidateEmail(email string) error {
	// Clean input
	cleanedEmail := strings.TrimSpace(email)
	
	// Check for empty email
	if cleanedEmail == "" {
		return errors.New("email is required")
	}
	
	// Compile email validation regex
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	
	// Test email format
	if !emailRegex.MatchString(cleanedEmail) {
		return errors.New("invalid email format")
	}
	
	return nil
}

func ValidateName(name string) error {
	// Clean input
	cleanedName := strings.TrimSpace(name)
	
	// Check name length constraints
	if len(cleanedName) < 2 || len(cleanedName) > 50 {
		return errors.New("name must be 2-50 characters")
	}
	
	return nil
}

func ValidatePassword(password string) error {
	// Check minimum length
	if len(password) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	
	// Define character type patterns
	uppercasePattern := regexp.MustCompile(`[A-Z]`)
	lowercasePattern := regexp.MustCompile(`[a-z]`)
	digitPattern := regexp.MustCompile(`[0-9]`)
	
	// Check for uppercase letter
	if !uppercasePattern.MatchString(password) {
		return errors.New("password must contain at least one uppercase letter")
	}
	
	// Check for lowercase letter
	if !lowercasePattern.MatchString(password) {
		return errors.New("password must contain at least one lowercase letter")
	}
	
	// Check for digit
	if !digitPattern.MatchString(password) {
		return errors.New("password must contain at least one number")
	}
	
	return nil
}


func (u *User) UpdateName(name string) error {
	// Validate new name
	if nameError := ValidateName(name); nameError != nil {
		return nameError
	}
	
	// Update name and timestamp
	u.Name = strings.TrimSpace(name)
	u.UpdatedAt = time.Now()
	
	return nil
}


func (u *User) UpdateEmail(email string) error {
	// Validate new email
	if emailError := ValidateEmail(email); emailError != nil {
		return emailError
	}
	
	// Update email and timestamp
	u.Email = strings.ToLower(strings.TrimSpace(email))
	u.UpdatedAt = time.Now()
	
	return nil
}