package models

import (
	"database/sql"
	"time"
	"fmt"
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

// Validates Post
func (p *Post) Validate() error {
	if p.Title == "" || len(p.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}
	if p.Published && p.Content == "" {
		return fmt.Errorf("content must not be empty if the post is published")
	}
	if p.UserID <= 0 {
		return fmt.Errorf("user_id must be greater than 0")
	}
	return nil
}

// Validates CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	if req.Title == "" || len(req.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}
	if req.UserID <= 0 {
		return fmt.Errorf("user_id must be greater than 0")
	}
	if req.Published && req.Content == "" {
		return fmt.Errorf("content must not be empty if the post is published")
	}
	return nil
}

// Converts CreatePostRequest to Post
func (req *CreatePostRequest) ToPost() *Post {
	return &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// Scans database row into Post struct
func (p *Post) ScanRow(row *sql.Row) error {
	err := row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
	if err != nil {
		return err
	}
	return nil
}

// Scans multiple database rows into Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	for rows.Next() {
		var post Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	rows.Close()
	return posts, nil
}
