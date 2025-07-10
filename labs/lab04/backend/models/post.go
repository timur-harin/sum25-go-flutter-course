package models

import (
	"database/sql"
	"errors"
	"time"
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
	if len(p.Title) < 5 {
		return errors.New("invalid title")
	}

	if p.Published == true && p.Content == "" {
		return errors.New("empty content")
	}

	if p.UserID < 1 {
		return errors.New("invalid id")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(req.Title) < 5 {
		return errors.New("invalid title")
	}

	if req.Published == true && req.Content == "" {
		return errors.New("empty content")
	}

	if req.UserID < 1 {
		return errors.New("invalid id")
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	return &Post{
		Title:     req.Title,
		Content:   req.Content,
		UserID:    req.UserID,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (p *Post) ScanRow(row *sql.Row) error {
	if err := row.Scan(p); err != nil {
		return err
	}
	return nil
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	for rows.Next() {
		var post Post
		if err := rows.Scan(&post); err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}
