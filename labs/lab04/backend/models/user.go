package models

import (
    "database/sql"
    "errors"
    "net/mail"
    "strings"
    "time"
)

// User represents a user in the system
// (fields declaration unchanged)

type User struct {
    ID        int       `json:"id" db:"id"`
    Name      string    `json:"name" db:"name"`
    Email     string    `json:"email" db:"email"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest represents the payload for creating a user
// (struct declaration unchanged)

type CreateUserRequest struct {
    Name  string `json:"name"`
    Email string `json:"email"`
}

type UpdateUserRequest struct {
    Name  *string `json:"name,omitempty"`
    Email *string `json:"email,omitempty"`
}

// Validate validates the User fields.
func (u *User) Validate() error {
    if len(strings.TrimSpace(u.Name)) < 2 {
        return errors.New("name must be at least 2 characters long")
    }
    if _, err := mail.ParseAddress(u.Email); err != nil {
        return errors.New("invalid email format")
    }
    return nil
}

// Validate validates the CreateUserRequest fields.
func (req *CreateUserRequest) Validate() error {
    if len(strings.TrimSpace(req.Name)) < 2 {
        return errors.New("name must be at least 2 characters long")
    }
    if _, err := mail.ParseAddress(req.Email); err != nil {
        return errors.New("invalid email format")
    }
    return nil
}

// ToUser converts a CreateUserRequest into a User entity.
func (req *CreateUserRequest) ToUser() *User {
    now := time.Now()
    return &User{
        Name:      req.Name,
        Email:     req.Email,
        CreatedAt: now,
        UpdatedAt: now,
    }
}

// ScanRow scans a single sql.Row into the User.
func (u *User) ScanRow(row *sql.Row) error {
    if row == nil {
        return errors.New("row is nil")
    }
    return row.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt)
}

// ScanUsers scans sql.Rows into a slice of User structs.
func ScanUsers(rows *sql.Rows) ([]User, error) {
    if rows == nil {
        return nil, errors.New("rows is nil")
    }
    defer rows.Close()

    var users []User
    for rows.Next() {
        var u User
        if err := rows.Scan(&u.ID, &u.Name, &u.Email, &u.CreatedAt, &u.UpdatedAt); err != nil {
            return nil, err
        }
        users = append(users, u)
    }
    return users, rows.Err()
}