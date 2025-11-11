package models

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
)

// User represents a user in the system
type User struct {
	ID        int       `json:"id" db:"id"`
	Name      string    `json:"name" db:"name" validate:"required,min=2"`
	Email     string    `json:"email" db:"email" validate:"required,email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest represents the payload for creating a user
type CreateUserRequest struct {
	Name  string `json:"name" validate:"required,min=2"`
	Email string `json:"email" validate:"required,email"`
}

// UpdateUserRequest represents the payload for updating a user
type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty" validate:"min=2"`
	Email *string `json:"email,omitempty" validate:"email"`
}

func (u *User) Validate() error {
	return validate.Struct(u)
}

func (req *CreateUserRequest) Validate() error {
	return validate.Struct(req)
}

func (req *CreateUserRequest) ToUser() *User {
	return &User{
		Name: req.Name,
		Email: req.Email,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errNilRow
	}
	err := row.Scan(
		&u.ID, &u.Name, &u.Email,
		&u.CreatedAt, &u.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return fmt.Errorf("user not found: %w", err)
		}
		return err
	}
	return nil
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, errNilRows
	}
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
	
	if err := rows.Err(); err != nil {
		return nil, err
	}
	
	return users, nil
}