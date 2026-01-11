package models

import (
	"database/sql"
	"fmt"
	"strings"
	"time"
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
	if u.Name == "" || len(u.Name) < 2 {
		return fmt.Errorf("invalid name")
	}
	if !strings.Contains(u.Email, "@") || !strings.Contains(u.Email, ".") {
		return fmt.Errorf("invalid email")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if req.Name == "" || len(req.Name) < 2 {
		return fmt.Errorf("invalid name")
	}
	if req.Email == "" || !strings.Contains(req.Email, "@") || !strings.Contains(req.Email, ".") {
		return fmt.Errorf("invalid email")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
	)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User
	for rows.Next() {
		var user User
		err := rows.Scan(
			&user.ID,
			&user.Name,
			&user.Email,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	return users, nil
}
