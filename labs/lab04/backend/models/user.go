package models

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
	"time"
)

var (
	ErrInvalidName = errors.New("name at least 2 characters")
	ErrInvalidEmail = errors.New("email must be a valid format")
	ErrNoRows = sql.ErrNoRows
	emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
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
	if len(u.Name) < 2 {
		return ErrInvalidName
	}

	if matched := emailRegex.MatchString(u.Email); !matched {
		return ErrInvalidEmail
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return ErrInvalidName
	}

	if matched := emailRegex.MatchString(req.Email); !matched {
		return ErrInvalidEmail
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now().UTC(),
		UpdatedAt: time.Now().UTC(),
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	err := row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNoRows
		}
		return fmt.Errorf("scan User row: %w", err)
	}
	return nil
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {

		}
	}(rows)

	var users []User

	for rows.Next() {
		var u User
		err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan Users rows: %w", err)
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %w", err)
	}
	return users, nil
}
