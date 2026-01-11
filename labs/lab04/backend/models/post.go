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

// Implement Validate method for Post
func (p *Post) Validate() error {
	// Add validation logic
	// - Title should not be empty and should be at least 5 characters
	if len(p.Title) < 5 {
		return errors.New("title should be at least 5 characters")
	}
	// - Content should not be empty if published is true
	if p.Published && len(p.Content) == 0 {
		return errors.New("content should not be empty if published is true")
	}
	// - UserID should be greater than 0
	if p.UserID <= 0 {
		return errors.New("post's UserID should be greater than 0")
	}
	// Return appropriate errors if validation fails
	return nil
}

// Implement Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	// Add validation logic
	// - Title should not be empty and should be at least 5 characters
	if len(req.Title) < 5 {
		return errors.New("title should be at least 5 characters")
	}
	// - Content should not be empty if published is true
	if req.Published && len(req.Content) == 0 {
		return errors.New("content should not be empty if published is true")
	}
	// - UserID should be greater than 0
	if req.UserID <= 0 {
		return errors.New("post's UserID should be greater than 0")
	}
	// Return appropriate errors if validation fails
	return nil
}

// Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	// Convert CreatePostRequest to Post
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

// Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	// Scan database row into Post struct
	// Handle the case where row might be nil
	if row == nil {
		return errors.New("sql row is nil")
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
	if err == nil {
		return err
	}
	return nil
}

// Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// Scan multiple database rows into Post slice
	// Make sure to close rows and handle errors properly
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
		if err == nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}
