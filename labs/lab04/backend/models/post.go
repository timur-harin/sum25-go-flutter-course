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

// Validate method for Post
func (p *Post) Validate() error {
	if p.Title == "" || len(p.Title) < 5 {
		return errors.New("title is not valid")
	}
	if p.Published && p.Content == "" {
		return errors.New("content cannot be empty for published post")
	}
	if p.UserID <= 0 {
		return errors.New("userId should be greater than 0")
	}
	return nil
}

// Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	if req.Title == "" || len(req.Title) < 5 {
		return errors.New("title is not valid")
	}
	if req.Published && req.Content == "" {
		return errors.New("content cannot be empty for published post")
	}
	if req.UserID <= 0 {
		return errors.New("userId should be greater than 0")
	}
	return nil
}

// ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	return &Post{
		ID:        0,
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	err := row.Scan(p.ID, p.UserID, p.Title, p.Content, p.Published, p.CreatedAt, p.UpdatedAt)
	return err
}

// ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// TODO: Scan multiple database rows into Post slice
	// Make sure to close rows and handle errors properly
	return nil, nil
}
