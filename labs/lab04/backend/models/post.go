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

// TODO: Implement Validate method for Post
func (p *Post) Validate() error {
	// TODO: Add validation logic
	// - Title should not be empty and should be at least 5 characters
	// - Content should not be empty if published is true
	// - UserID should be greater than 0
	// Return appropriate errors if validation fails
	if len(p.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if p.Published && p.Content == "" {
		return errors.New("content is required when post is published")
	}
	if p.UserID <= 0 {
		return errors.New("invalid user id")
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
		return errors.New("title must be at least 5 characters")
	}
	if req.UserID <= 0 {
		return errors.New("invalid user id")
	}
	if req.Published && req.Content == "" {
		return errors.New("content is required when post is published")
	}
	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	// TODO: Convert CreatePostRequest to Post
	// Set timestamps to current time
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
	// TODO: Scan database row into Post struct
	// Handle the case where row might be nil
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// TODO: Scan multiple database rows into Post slice
	// Make sure to close rows and handle errors properly
	if rows == nil {
		return nil, errors.New("rows is nil")
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var p Post
		if err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt); err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return posts, nil
}
