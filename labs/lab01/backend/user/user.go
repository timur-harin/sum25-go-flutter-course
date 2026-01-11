package user

import (
	"errors"
	"strconv"
)

// Predefined errors
var (
	ErrInvalidName  = errors.New("invalid name: must be between 1 and 30 characters")
	ErrInvalidAge   = errors.New("invalid age: must be between 0 and 150")
	ErrInvalidEmail = errors.New("invalid email format")
)

// User represents a user in the system
type User struct {
	Name  string
	Age   int
	Email string
}

// NewUser creates a new user with validation
func NewUser(name string, age int, email string) (*User, error) {
	userPtr := &User{Name: name, Age: age, Email: email}
	return userPtr, userPtr.Validate()
}

// Validate checks if the user data is valid
func (u *User) Validate() error {
	// Name cannot be empty
	if len(u.Name) == 0 {
		return ErrInvalidName
	}

	// Check user's age
	if u.Age < 0 || u.Age > 150 {
		return ErrInvalidAge
	}

	// Check the email
	if IsValidEmail(u.Email) {
		return nil
	}

	return ErrInvalidEmail
}

// String returns a string representation of the user, formatted as "Name: <name>, Age: <age>, Email: <email>"
func (u *User) String() string {
	var ret string = "Name: " + u.Name + ", Age: "          // write name info
	ret += string(strconv.AppendInt(nil, int64(u.Age), 10)) // write age info
	ret += ", Email: " + u.Email                            // write email info

	return ret
}

// IsValidEmail checks if the email format is valid
// You can use regexp.MustCompile to compile the email regex
func IsValidEmail(email string) bool {
	// Check the email (start with checking it's length)
	if len(email) == 0 {
		return false
	}

	// Check for exactly one '@' symbol and exactly one '.' symbol after it,
	// and part before '@' to be non-empty
	var readCnt int = 0 // count of symbol read by a moment
	var atCnt int = 0   // is '@' symbol read
	var dotsCnt int = 0 // count of '.' symbols read after '@' symbol was read
	for i, ch := range email {
		i++       // just to use it somehow
		readCnt++ // increase the count of symbols read

		if ch == '@' {
			atCnt++ // increase the count of '@' symbols read

			// since no more than one '@' is allowed
			// and part before '@' must not be empty
			if atCnt > 1 || readCnt == 1 {
				return false
			}
		}

		if ch == '.' {
			if atCnt != 0 { // do not count dots before the '@' symbol is met
				dotsCnt++
			}

			// since no more than one '.' is allowed after '@' was read
			if atCnt > 0 && dotsCnt > 1 {
				return false
			}
		}
	}

	// no '@' or '.' symbols found
	if atCnt == 0 || dotsCnt == 0 {
		return false
	}

	return true // OK - valid email
}

// IsValidAge checks if the age is valid, returns false if the age is not between 0 and 150
func IsValidAge(age int) bool {
	// TODO: Implement this function
	return false
}
