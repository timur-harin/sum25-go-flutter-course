package models

import (
	"database/sql"
	"errors"
	"regexp"
	"strings"
	"time"
)

type User struct {
	ID           int        `json:"id" db:"id"`
	Name         string     `json:"name" db:"name"`
	Email        string     `json:"email" db:"email"`
	PasswordHash *string    `json:"password_hash" db:"password_hash"` // ← вот тут
	CreatedAt    time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at" db:"updated_at"`
	DeletedAt    *time.Time `json:"deleted_at,omitempty" db:"deleted_at"` // nullable
}

type CreateUserRequest struct {
	Name         string `json:"name"`
	Email        string `json:"email"`
	PasswordHash string `json:"password_hash"`
}

type UpdateUserRequest struct {
	Name         *string `json:"name"`
	Email        *string `json:"email"`
	PasswordHash *string `json:"password_hash"`
}

func (u *User) Validate() error {
	if len(strings.TrimSpace(u.Name)) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if !isValidEmail(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if !isValidEmail(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	var users []User
	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	return users, rows.Err()
}

// isValidEmail checks if the email has a valid format using a simple regex.
func isValidEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(pattern)
	return re.MatchString(email)
}

func (r *UpdateUserRequest) Validate() error {
	if r.Name == nil || len(strings.TrimSpace(*r.Name)) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if r.Email == nil || len(strings.TrimSpace(*r.Email)) < 5 || !containsAt(*r.Email) {
		return errors.New("invalid email")
	}
	if r.PasswordHash != nil && len(strings.TrimSpace(*r.PasswordHash)) < 8 {
		return errors.New("password hash too short")
	}
	return nil
}

func containsAt(email string) bool {
	for _, c := range email {
		if c == '@' {
			return true
		}
	}
	return false
}
