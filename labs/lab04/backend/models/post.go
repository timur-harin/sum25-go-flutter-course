package models

import (
	"database/sql"
	"errors"
	"fmt"
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

var (
	ErrInvalidTitle   = errors.New("title should not be empty and should be at least 5 characters")
	ErrInvalidContent = errors.New("content should not be empty if published is true")
	ErrInvalidUserID  = errors.New("user_id should be greater than 0")
)

// TODO: Implement Validate method for Post
func (p *Post) Validate() error {
	// TODO: Add validation logic
	// - Title should not be empty and should be at least 5 characters
	// - Content should not be empty if published is true
	// - UserID should be greater than 0
	// Return appropriate errors if validation fails

	if len(p.Title) < 5 {
		return ErrInvalidTitle
	}

	if p.Published && len(p.Content) < 1 {
		return ErrInvalidContent
	}

	if !(p.UserID > 0) {
		return ErrInvalidUserID
	}

	return nil
}

// TODO: Implement Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	// TODO: Add validation logic
	// - Title should not be empty and should be at least 5 characters
	// - UserID should be greater than 0
	// - Content should not be empty if published is true
	// Return appropriate errors if validation fails

	if len(req.Title) < 5 {
		return ErrInvalidTitle
	}

	if !(req.UserID > 0) {
		return ErrInvalidUserID
	}

	if req.Published && len(req.Content) < 1 {
		return ErrInvalidContent
	}

	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	// TODO: Convert CreatePostRequest to Post
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

// ScanRow scans a row from sql.Row into the Post. Returns error if scan failed
func (p *Post) ScanRow(row *sql.Row) error {
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

// ScanPosts scans rows into Post slice. Returns error if scan failed
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, sql.ErrNoRows
	}
	defer rows.Close()

	posts := make([]Post, 0, 8)

	for rows.Next() {
		var post Post
		if err := rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Published,
			&post.CreatedAt,
			&post.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("error scanning row: %w", err)
		}
		posts = append(posts, post)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %w", err)
	}

	return posts, nil
}
