package models

import (
	"database/sql"
	"errors"
	"time"
)

// functions to validate title
func _isValidTitle(title string) bool {
	if len(title) < 5 || title == "" {
		return false
	}
	return true
}

// functions to validate content
func _isValidContent(content string, published bool) bool {
	if published && len(content) == 0 {
		return false
	}
	return true
}

// functions to validate user ID
func _isValidUserID(userID int) bool {
	if userID <= 0 {
		return false
	}
	return true
}

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
	if !_isValidTitle(p.Title) {
		return errors.New("Title should not be empty and should be at least 5 characters")
	}
	if !_isValidContent(p.Content, p.Published) {
		return errors.New("Content should not be empty if published is true")
	}
	if !_isValidUserID(p.UserID) {
		return errors.New("UserID should be greater than 0")
	}
	return nil
}

// Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	if !_isValidTitle(req.Title) {
		return errors.New("Title should not be empty and should be at least 5 characters")
	}
	if !_isValidUserID(req.UserID) {
		return errors.New("UserID should be greater than 0")
	}
	if !_isValidContent(req.Content, req.Published) {
		return errors.New("Content should not be empty if published is true")
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

// ScanRow scans a single sql.Row into the Post struct
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

// ScanPosts scans multiple sql.Rows into a slice of Post structs
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
