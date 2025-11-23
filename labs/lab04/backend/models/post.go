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
		return ErrInvalidPostTitle
	}
	if p.Published && len(p.Content) == 0 {
		return ErrInvalidPostContent
	}
	if p.UserID <= 0 {
		return ErrInvalidUserID
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(req.Title) < 5 {
		return ErrInvalidPostTitle
	}
	if req.Published && len(req.Content) == 0 {
		return ErrInvalidPostContent
	}
	if req.UserID <= 0 {
		return ErrInvalidUserID
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	return &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

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

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer rows.Close()
	var posts []Post

	for rows.Next() {
		var post Post
		err := rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Published,
			&post.CreatedAt,
			&post.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}

	if err := rows.Err(); err != nil {
		return nil, err
	}

	return posts, nil
}

var (
	ErrInvalidPostTitle   = errors.New("title must be at least 5 characters")
	ErrInvalidPostContent = errors.New("content cannot be empty when published")
	ErrInvalidUserID      = errors.New("user_id must be greater than 0")
)
