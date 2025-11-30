package models

import (
	"database/sql"
	"errors"
	"time"
	"regexp"
)

var (
	emailRegex      = regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	ErrNameTooShort = errors.New("name must be at least 2 characters")
	ErrEmailInvalid = errors.New("invalid email format")
)

type User struct {
	ID        int        `json:"id" db:"id"`
	Name      string     `json:"name" db:"name"`
	Email     string     `json:"email" db:"email"`
	CreatedAt time.Time  `json:"created_at" db:"created_at"`
	UpdatedAt time.Time  `json:"updated_at" db:"updated_at"`
	DeletedAt *time.Time `json:"-" db:"deleted_at"`
}

type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

func validateUserFields(name, email string) error {
	if len(name) < 2 {
		return ErrNameTooShort
	}
	if !emailRegex.MatchString(email) {
		return ErrEmailInvalid
	}
	return nil
}

func (u *User) Validate() error {
	return validateUserFields(u.Name, u.Email)
}

func (req *CreateUserRequest) Validate() error {
	return validateUserFields(req.Name, req.Email)
}

func (req *UpdateUserRequest) Validate() error {
	if req.Name != nil || req.Email != nil {
		name := ""
		if req.Name != nil {
			name = *req.Name
		}
		email := ""
		if req.Email != nil {
			email = *req.Email
		}
		return validateUserFields(name, email)
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
	return row.Scan(
		&u.ID,
		&u.Name,
		&u.Email,
		&u.CreatedAt,
		&u.UpdatedAt,
		&u.DeletedAt,
	)
}

func ScanUsers(rows *sql.Rows) ([]User, error) {
	var users []User
	defer rows.Close()

	for rows.Next() {
		var u User
		if err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
			&u.DeletedAt,
		); err != nil {
			return nil, err
		}
		users = append(users, u)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

func (u *User) IsDeleted() bool {
	return u.DeletedAt != nil
}

func (u *User) BeforeCreate() error {
	u.CreatedAt = time.Now()
	u.UpdatedAt = time.Now()
	return u.Validate()
}

func (u *User) BeforeUpdate() error {
	u.UpdatedAt = time.Now()
	return u.Validate()
}