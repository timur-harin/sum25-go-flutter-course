package models

import (
	"database/sql"
	"errors"
	"strings"
	"time"
)

// -----------------------------------------------------------------------------
// Модель Post
// -----------------------------------------------------------------------------

type Post struct {
	ID        int       `json:"id"         db:"id"`
	UserID    int       `json:"user_id"    db:"user_id"`
	Title     string    `json:"title"      db:"title"`
	Content   string    `json:"content"    db:"content"`
	Published bool      `json:"published"  db:"published"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// -----------------------------------------------------------------------------
// DTO ­— запросы на создание / обновление
// -----------------------------------------------------------------------------

type CreatePostRequest struct {
	UserID    int    `json:"user_id"`
	Title     string `json:"title"`
	Content   string `json:"content"`
	Published bool   `json:"published"`
}

type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty"`
	Content   *string `json:"content,omitempty"`
	Published *bool   `json:"published,omitempty"`
}

// -----------------------------------------------------------------------------
// Валидация
// -----------------------------------------------------------------------------

func (p *Post) Validate() error {
	p.Title = strings.TrimSpace(p.Title)
	p.Content = strings.TrimSpace(p.Content)

	if p.UserID <= 0 {
		return errors.New("user_id must be positive")
	}
	if len(p.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if p.Published && p.Content == "" {
		return errors.New("content cannot be empty when post is published")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	req.Title = strings.TrimSpace(req.Title)
	req.Content = strings.TrimSpace(req.Content)

	if req.UserID <= 0 {
		return errors.New("user_id must be positive")
	}
	if len(req.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if req.Published && req.Content == "" {
		return errors.New("content cannot be empty when post is published")
	}
	return nil
}

// -----------------------------------------------------------------------------
// Преобразование запроса → модель
// -----------------------------------------------------------------------------

func (req *CreatePostRequest) ToPost() *Post {
	now := time.Now()
	return &Post{
		UserID:    req.UserID,
		Title:     strings.TrimSpace(req.Title),
		Content:   strings.TrimSpace(req.Content),
		Published: req.Published,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// -----------------------------------------------------------------------------
// Сканирование из базы
// -----------------------------------------------------------------------------

// ScanRow считывает одну строку (QueryRow) в структуру Post.
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(
		&p.ID,
		&p.UserID,
		&p.Title,
		&p.Content,
		&p.Published,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
}

// ScanPosts считывает несколько строк (Query) в срез Post.
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, errors.New("rows is nil")
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var p Post
		if err := rows.Scan(
			&p.ID,
			&p.UserID,
			&p.Title,
			&p.Content,
			&p.Published,
			&p.CreatedAt,
			&p.UpdatedAt,
		); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}

	return posts, nil
}
