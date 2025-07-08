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

// Validate validates the Post struct
func (p *Post) Validate() error {
	// Title should not be empty and should be at least 5 characters
	if len(p.Title) < 5 {
		return errors.New("title should not be empty and should be at least 5 characters")
	}
	// Content should not be empty if published is true
	if p.Published && len(p.Content) == 0 {
		return errors.New("content should not be empty if published is true")
	}
	// UserID should be greater than 0
	if p.UserID <= 0 {
		return errors.New("userID should be greater than 0")
	}
	return nil
}

// Validate validates the CreatePostRequest struct
func (req *CreatePostRequest) Validate() error {
	// Title should not be empty and should be at least 5 characters
	if len(req.Title) < 5 {
		return errors.New("title should not be empty and should be at least 5 characters")
	}
	// UserID should be greater than 0
	if req.UserID <= 0 {
		return errors.New("userID should be greater than 0")
	}
	// Content should not be empty if published is true
	if req.Published && len(req.Content) == 0 {
		return errors.New("content should not be empty if published is true")
	}
	return nil
}

// ToPost converts CreatePostRequest to Post
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

// ScanRow scans a single sql.Row into Post
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		// Return error if row is nil
		return errors.New("row is nil")
	}
	// Scan row into Post struct
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// ScanPosts scans multiple sql.Rows into a slice of Post
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer rows.Close() // Always close rows after use
	var posts []Post
	for rows.Next() {
		var p Post
		// Scan each row into a Post struct
		err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	// Check for errors after iteration
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return posts, nil
}
