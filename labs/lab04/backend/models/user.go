package models

import (
	"database/sql"
	"errors"
	"fmt"
	"regexp"
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
	regEmail := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !regEmail.MatchString(u.Email) {
		return fmt.Errorf("Email should be valid format")
	} else if len(u.Name) < 2 {
		return fmt.Errorf("Name should not be empty and should be at least 2 characters")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	regEmail := regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)
	if !regEmail.MatchString(req.Email) {
		return fmt.Errorf("Email should be valid format")
	} else if len(req.Name) < 2 {
		return fmt.Errorf("Name should not be empty and should be at least 2 characters")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	user := &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return user
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("nil row")
	}
	err := row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
	return err
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var users []User
	if rows == nil {
		return nil, errors.New("nil rows")
	}
	for rows.Next() {
		var user User
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %w", err)
	}
	return users, nil
}
