package models

import (
	"database/sql"
	"fmt"
	"time"
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
	if len(p.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}
	if p.Published && p.Content == "" {
		return fmt.Errorf("content cannot be empty for a published post")
	}
	if p.UserID <= 0 {
		return fmt.Errorf("user_id must be a positive integer")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(req.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}
	if req.Published && req.Content == "" {
		return fmt.Errorf("content cannot be empty for a published post")
	}
	if req.UserID <= 0 {
		return fmt.Errorf("user_id must be a positive integer")
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
	if row.Err() != nil {
		return row.Err()
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

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer rows.Close()
	var posts []Post
	for rows.Next() {
		var p Post
		if err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, fmt.Errorf("failed to scan post row: %w", err)
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error during rows iteration: %w", err)
	}
	return posts, nil
}
