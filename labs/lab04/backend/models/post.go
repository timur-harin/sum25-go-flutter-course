package models

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
)

var (
	ErrEmptyTitle        = errors.New("empty tittle")
	ErrShortTitle        = errors.New("short tittle")
	ErrEmptyContent      = errors.New("empty content")
	ErrNotPositiveUserID = errors.New("negative user id")
)

// Post represents a blog post in the system
type Post struct {
	ID        int       `json:"id" db:"id"`
	UserID    int       `json:"user_id" db:"user_id"`
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	Published bool      `json:"published" db:"published"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreatePostRequest represents the payload for creating a post
type CreatePostRequest struct {
	UserID    int    `json:"user_id"`
	Title     string `json:"title"`
	Content   string `json:"content"`
	Published bool   `json:"published"`
}

// UpdatePostRequest represents the payload for updating a post
type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty"`
	Content   *string `json:"content,omitempty"`
	Published *bool   `json:"published,omitempty"`
}

func (p *Post) Validate() error {
	if p.Title == "" {
		return ErrEmptyTitle
	}
	if len(p.Title) < 5 {
		return ErrShortTitle
	}
	if p.Content == "" && p.Published {
		return ErrEmptyContent
	}
	if p.UserID <= 0 {
		return ErrNotPositiveUserID
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if req.Title == "" {
		return ErrEmptyTitle
	}
	if len(req.Title) < 5 {
		return ErrShortTitle
	}
	if req.UserID <= 0 {
		return ErrNotPositiveUserID
	}
	if req.Content == "" && req.Published {
		return ErrEmptyContent
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	now := time.Now()
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
	if row == nil {
		return errors.New("ScanRow: nil *sql.Row")
	}
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
			return err
		}
		return fmt.Errorf("ScanRow: %w", err)
	}
	return nil
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
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
			return nil, fmt.Errorf("ScanPosts: scan error: %w", err)
		}

		posts = append(posts, p)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("ScanPosts: rows iteration error: %w", err)
	}

	return posts, nil
}
