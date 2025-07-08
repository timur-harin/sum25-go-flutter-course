package models

import (
	"database/sql"
	"fmt"
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

type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

func (u *User) Validate() error {
	err := validate.Struct(struct {
		Name  string `validate:"required,min=2"`
		Email string `validate:"required,email"`
	}{
		Name:  u.Name,
		Email: u.Email,
	})
	if err != nil {
		return fmt.Errorf("validation failed: %w", err)
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	err := validate.Struct(struct {
		Name  string `validate:"required,min=2"`
		Email string `validate:"required,email"`
	}{
		Name:  req.Name,
		Email: req.Email,
	})
	if err != nil {
		return fmt.Errorf("validation failed: %w", err)
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
	defer rows.Close()
	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
			return nil, err
		}
		users = append(users, u)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return users, nil
}