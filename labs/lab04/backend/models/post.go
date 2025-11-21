package models

import (
	"database/sql"
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

// TODO: Implement Validate method for Post
func (p *Post) Validate() error {
	// TODO: Add validation logic
	// - Title should not be empty and should be at least 5 characters
	if p.Title == "" {
		return fmt.Errorf("title should not be happy")
	}
	if len(p.Title) < 5{
		return fmt.Errorf("title should be at least 5 characters")
	}

	// - Content should not be empty if published is true
	if p.Published && p.Content == ""{
		return fmt.Errorf("content should not be empty if published is true")
	}
	// - UserID should be greater than 0
	if p.UserID <= 0{
		return fmt.Errorf("userID should be greater than 0")
	}
	// Return appropriate errors if validation fails
	return nil
}

// TODO: Implement Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	// TODO: Add valdation logic
	// - Title should not be empty and should be at least 5 characters
	if req.Title == "" {
		return fmt.Errorf("title should not be happy")
	}
	if len(req.Title) < 5{
		return fmt.Errorf("title should be at least 5 characters")
	}

	// - Content should not be empty if published is true
	if req.Published && req.Content == ""{
		return fmt.Errorf("content should not be empty if published is true")
	}
	// - UserID should be greater than 0
	if req.UserID <= 0{
		return fmt.Errorf("userID should be greater than 0")
	}
	// Return appropriate errors if validation fails
	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	now := time.Now()
	return &Post{
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		UserID:    req.UserID,
		CreatedAt: now,
		UpdatedAt: now,
	}
}

// TODO: Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}
	return row.Scan(
		&p.ID,
		&p.Title,
		&p.Content,
		&p.Published,
		&p.UserID,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer rows.Close()
	var posts []Post
	for rows.Next() {
		var p Post
		err := rows.Scan(
			&p.ID,
			&p.Title,
			&p.Content,
			&p.Published,
			&p.UserID,
			&p.CreatedAt,
			&p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return posts, nil
}
