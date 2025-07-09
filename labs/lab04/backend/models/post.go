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
	if p.Title == "" || len(p.Title) < 5 {
		return errors.New("title is empty or too short")
	}
	if p.Published && p.Content == "" {
		return errors.New("if published, content could not be empty")
	}
	if p.UserID <= 0 {
		return errors.New("user_id is not valid")
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
	if req.UserID <= 0 {
		return errors.New("user_id is not valid")
	}
	if req.Title == "" || len(req.Title) < 5 {
		return errors.New("title is empty or too short")
	}
	if req.Published && req.Content == "" {
		return errors.New("content is empty")
	}
	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	// TODO: Convert CreatePostRequest to Post
	// Set timestamps to current time
	post := &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
	}
	return post
}

// TODO: Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into Post struct
	// Handle the case where row might be nil
	err := row.Scan(&p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt)
	if err != nil {
		return err
	}
	return nil
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// TODO: Scan multiple database rows into Post slice
	// Make sure to close rows and handle errors properly
	var posts []Post
	err := rows.Scan(posts)
	if err != nil {
		return nil, err
	}
	return posts, nil
}
