package models

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"time"
)

var (
	emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

	ErrEmptyName    = errors.New("empty name")
	ErrShortName    = errors.New("short name")
	ErrEmptyEmail   = errors.New("empty email")
	ErrInvalidEmail = errors.New("invalid email")
)

// User represents a user in the system
type User struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest represents the payload for creating a user
type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

// UpdateUserRequest represents the payload for updating a user
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

func (u *User) Validate() error {
	if u.Name == "" {
		return ErrEmptyName
	}
	if len(u.Name) < 2 {
		return ErrShortName
	}
	if u.Email == "" {
		return ErrEmptyEmail
	}
	if !emailRegex.MatchString(u.Email) {
		return ErrInvalidEmail
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if req.Name == "" {
		return ErrEmptyName
	}
	if len(req.Name) < 2 {
		return ErrShortName
	}
	if req.Email == "" {
		return ErrEmptyEmail
	}
	if !emailRegex.MatchString(req.Email) {
		return ErrInvalidEmail
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
	if row == nil {
		return errors.New("ScanRow: nil *sql.Row")
	}

	err := row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return err
		}
		return fmt.Errorf("ScanRow: scan error: %w", err)
	}

	return nil
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()

	var users []User

	for rows.Next() {
		var u User

		if err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("ScanUsers: scan error: %w", err)
		}

		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("ScanUsers: rows iteration error: %w", err)
	}

	return users, nil
}
