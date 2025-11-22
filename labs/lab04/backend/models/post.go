package models

import (
	"database/sql"
	"errors"
	"time"
)

var (
	ErrInvalidTitle   = errors.New("invalid title")
	ErrInvalidContent = errors.New("invalid content")
	ErrInvalidID      = errors.New("invalid id")
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
	// - Title should not be empty and should be at least 5 characters
	// - Content should not be empty if published is true
	// - UserID should be greater than 0

	if len(p.Title) < 5 {
		return ErrInvalidTitle
	}
	if len(p.Content) == 0 && p.Published {
		return ErrInvalidContent
	}
	if p.UserID <= 0 {
		return ErrInvalidID
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	// - Title should not be empty and should be at least 5 characters
	// - UserID should be greater than 0
	// - Content should not be empty if published is true

	if len(req.Title) < 5 {
		return ErrInvalidTitle
	}
	if len(req.Content) == 0 && req.Published {
		return ErrInvalidContent
	}
	if req.UserID <= 0 {
		return ErrInvalidID
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	// Set timestamps to current time

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
	// Handle the case where row might be nil

	if row == nil {
		return ErrNilRow
	}
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published)
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// Make sure to close rows and handle errors properly

	if rows == nil {
		return []Post{}, ErrNilRow
	}
	posts := make([]Post, 0)

	for rows.Next() {
		var p Post
		err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published)
		if err != nil {
			return []Post{}, err
		}
		posts = append(posts, p)
	}
	return posts, nil
}
