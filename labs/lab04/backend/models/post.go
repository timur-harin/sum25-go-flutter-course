package models

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
)

var (
	ErrInvalidTitle   = errors.New("title must be at least 5 characters")
	ErrInvalidContent = errors.New("content must not be empty when published")
	ErrInvalidUserID  = errors.New("user_id must be greater than 0")
)

type Post struct {
	ID        int       `json:"id" db:"id"`
	UserID    int       `json:"user_id" db:"user_id"`
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	Published bool      `json:"published" db:"published"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

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

func (p *Post) Validate() error {
	if p.UserID <= 0 {
		return ErrInvalidUserID
	}
	if len(p.Title) < 5 {
		return ErrInvalidTitle
	}
	if p.Published && len(p.Content) == 0 {
		return ErrInvalidContent
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if req.UserID <= 0 {
		return ErrInvalidUserID
	}
	if len(req.Title) < 5 {
		return ErrInvalidTitle
	}
	if req.Published && len(req.Content) == 0 {
		return ErrInvalidContent
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	now := time.Now().UTC()
	return &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

func (p *Post) ScanRow(row *sql.Row) error {
	err := row.Scan(
		&p.ID,
		&p.UserID,
		&p.Title,
		&p.Content,
		&p.Published,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrNoRows
		}
		return fmt.Errorf("scan Post row: %w", err)
	}
	return nil
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {
		}
	}(rows)

	var posts []Post
	for rows.Next() {
		var p Post
		err := rows.Scan(
			&p.ID,
			&p.UserID,
			&p.Title,
			&p.Content,
			&p.Published,
			&p.CreatedAt,
			&p.UpdatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("scan Posts rows: %w", err)
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %w", err)
	}
	return posts, nil
}
