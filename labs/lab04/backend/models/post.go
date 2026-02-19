package models

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
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

// TODO: Implement Validate method for Post
func (p *Post) Validate() error {
	// Title validation
	if strings.TrimSpace(p.Title) == "" {
		return errors.New("title cannot be empty")
	}
	if len(strings.TrimSpace(p.Title)) < 5 {
		return errors.New("title must be at least 5 characters long")
	}

	// UserID validation
	if p.UserID <= 0 {
		return errors.New("user ID must be greater than 0")
	}

	// Content validation for published posts
	if p.Published && strings.TrimSpace(p.Content) == "" {
		return errors.New("content cannot be empty for published posts")
	}

	return nil
}

// TODO: Implement Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	// Title validation
	if strings.TrimSpace(req.Title) == "" {
		return errors.New("title cannot be empty")
	}
	if len(strings.TrimSpace(req.Title)) < 5 {
		return errors.New("title must be at least 5 characters long")
	}

	// UserID validation
	if req.UserID <= 0 {
		return errors.New("user ID must be greater than 0")
	}

	// Content validation for published posts
	if req.Published && strings.TrimSpace(req.Content) == "" {
		return errors.New("content cannot be empty for published posts")
	}

	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
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

// TODO: Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row cannot be nil")
	}

	err := row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		return fmt.Errorf("failed to scan post row: %w", err)
	}

	return nil
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, errors.New("rows cannot be nil")
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var post Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan post row: %w", err)
		}
		posts = append(posts, post)
	}

	// Check for errors from iterating over rows
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating over rows: %w", err)
	}

	return posts, nil
}
