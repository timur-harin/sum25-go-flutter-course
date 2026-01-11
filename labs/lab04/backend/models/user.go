package models

import (
	"database/sql"
	"errors"
	"net/mail"
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
	if u.Name == "" || len(u.Name) < 2 {
		return errors.New("name must be 2 or more characters")
	}
	_, emailErr := mail.ParseAddress(u.Email)
	if emailErr != nil {
		return errors.New("email format is invalid")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	if req.Name == "" || len(req.Name) < 2 {
		return errors.New("name requires at least 2 characters")
	}
	if req.Email == "" {
		return errors.New("email must not be empty")
	}
	_, err := mail.ParseAddress(req.Email)
	if err != nil {
		return errors.New("incorrect email format")
	}
	return nil
}

func (req *CreateUserRequest) ToUser() *User {
	currentTime := time.Now()
	return &User{
		Name:      req.Name,
		Email:     req.Email,
		CreatedAt: currentTime,
		UpdatedAt: currentTime,
	}
}

func (u *User) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("cannot scan a nil row")
	}
	return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	defer rows.Close()
	var userList []User
	for rows.Next() {
		user := User{}
		err := rows.Scan(&user.ID, &user.Name, &user.Email, &user.CreatedAt, &user.UpdatedAt)
		if err != nil {
			return nil, err
		}
		userList = append(userList, user)
	}
	if rowErr := rows.Err(); rowErr != nil {
		return nil, rowErr
	}
	return userList, nil
}