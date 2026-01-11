package models

import (
	"database/sql"
	"errors"
	"regexp"
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
	if len(strings.TrimSpace(u.Name)) == 0 || len(u.Name) < 2 {
		return errors.New("name should not be empty and should be at least 2 characters")
	}

	if u.Email == "" || regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).MatchString(u.Email) == false {
		return errors.New("invalid email")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) == 0 || len(req.Name) < 2 {
		return errors.New("name should not be empty and should be at least 2 characters")
	}

	if req.Email == "" || !regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`).MatchString(req.Email) {
		return errors.New("invalid email")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {

	time := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: time,
		UpdatedAt: time,
	}
}

func (u *User) ScanRow(row *sql.Row) error {

	if row == nil {
		return errors.New("row is nil")
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
	if rows == nil {
		return nil, errors.New("rows value is nil")
	}
	defer rows.Close() // ensures the database result set (rows) is closed at the end of the function
	var users []User

	for rows.Next() {
		var user User     // maps the columns from the current row into the fields of post
		err := rows.Scan( // uses pointers & so the values get written directly into the struct fields.
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
	if err := rows.Err(); err != nil { // ensures the row iteration didn't end due to a hidden error
		return nil, err
	}

	return users, nil
}
