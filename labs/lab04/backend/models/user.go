package models

import (
	"database/sql"
	"errors"
	"regexp"
	"strings"
	"time"
)

// -----------------------------------------------------------------------------
// Модель User
// -----------------------------------------------------------------------------

type User struct {
	ID        int       `json:"id"         db:"id"`
	Name      string    `json:"name"       db:"name"`
	Email     string    `json:"email"      db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// -----------------------------------------------------------------------------
// DTO — запросы на создание / обновление
// -----------------------------------------------------------------------------

type CreateUserRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type UpdateUserRequest struct {
	Name  *string `json:"name,omitempty"`
	Email *string `json:"email,omitempty"`
}

// -----------------------------------------------------------------------------
// Валидация
// -----------------------------------------------------------------------------

var emailRe = regexp.MustCompile(`^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$`)

func (u *User) Validate() error {
	u.Name = strings.TrimSpace(u.Name)
	u.Email = strings.TrimSpace(u.Email)

	if len(u.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if !emailRe.MatchString(u.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

func (req *CreateUserRequest) Validate() error {
	req.Name = strings.TrimSpace(req.Name)
	req.Email = strings.TrimSpace(req.Email)

	if len(req.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if req.Email == "" || !emailRe.MatchString(req.Email) {
		return errors.New("invalid email format")
	}
	return nil
}

// -----------------------------------------------------------------------------
// Преобразование запроса → модель
// -----------------------------------------------------------------------------

func (req *CreateUserRequest) ToUser() *User {
	now := time.Now()
	return &User{
		Name:      strings.TrimSpace(req.Name),
		Email:     strings.TrimSpace(req.Email),
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// -----------------------------------------------------------------------------
// Сканирование из базы
// -----------------------------------------------------------------------------

// ScanRow считывает результат QueryRow в структуру User.
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

// ScanUsers считывает несколько строк (sql.Rows) в срез User.
func ScanUsers(rows *sql.Rows) ([]User, error) {
	if rows == nil {
		return nil, errors.New("rows is nil")
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var u User
		if err := rows.Scan(
			&u.ID,
			&u.Name,
			&u.Email,
			&u.CreatedAt,
			&u.UpdatedAt,
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
