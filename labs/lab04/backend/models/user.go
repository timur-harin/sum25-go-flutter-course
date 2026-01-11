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
	if len(u.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}
	if u.Email == "" || !isValidEmail(u.Email) {
		return fmt.Errorf("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if len(req.Name) < 2 {
		return fmt.Errorf("name must be at least 2 characters")
	}
	if req.Email == "" || !isValidEmail(req.Email) {
		return fmt.Errorf("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	now := time.Now().UTC()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User
	for rows.Next() {
		var u User
		err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}

// isValidEmail is a simple email format checker
func isValidEmail(email string) bool {
	// Простейшая проверка: наличие @ и . после @
	at := strings.Index(email, "@")
	if at < 1 || at == len(email)-1 {
		return false
	}
	dot := strings.LastIndex(email, ".")
	return dot > at+1 && dot < len(email)-1
}
