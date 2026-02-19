package models

import (
	"database/sql"
	"errors"
	"strings"
	"time"
)

type User struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

// UpdateUserRequest represents the payload for updating a user
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

// Validate validates the User fields
func (u *User) Validate() error {
	if strings.TrimSpace(u.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if len(u.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if strings.TrimSpace(u.Email) == "" {
		return errors.New("email cannot be empty")
	}
	if !strings.Contains(u.Email, "@") {
		return errors.New("email must be valid")
	}
	return nil
}

// Validate validates the CreateUserRequest fields
func (req *CreateUserRequest) Validate() error {
	if strings.TrimSpace(req.Name) == "" {
		return errors.New("name cannot be empty")
	}
	if len(req.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if strings.TrimSpace(req.Email) == "" {
		return errors.New("email cannot be empty")
	}
	if !strings.Contains(req.Email, "@") {
		return errors.New("email must be valid")
	}
	return nil
}

// ToUser converts CreateUserRequest to User
func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// ScanRow scans a database row into the User struct
func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return sql.ErrNoRows
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans multiple rows into a slice of Users
func ScanUsers(rows *sql.Rows) ([]User, error) {
	var users []User
	defer rows.Close()

	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}
