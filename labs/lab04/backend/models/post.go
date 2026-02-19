package models

import (
	"database/sql"
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

// Validate validates Post fields
func (p *Post) Validate() error {
	if strings.TrimSpace(p.Title) == "" {
		return fmt.Errorf("title cannot be empty")
	}

	if len(strings.TrimSpace(p.Title)) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}

	if p.UserID <= 0 {
		return fmt.Errorf("user_id must be greater than 0")
	}

	if p.Published && strings.TrimSpace(p.Content) == "" {
		return fmt.Errorf("content cannot be empty when post is published")
	}

	return nil
}

// Validate validates CreatePostRequest fields
func (req *CreatePostRequest) Validate() error {
	if strings.TrimSpace(req.Title) == "" {
		return fmt.Errorf("title cannot be empty")
	}

	if len(strings.TrimSpace(req.Title)) < 5 {
		return fmt.Errorf("title must be at least 5 characters long")
	}

	if req.UserID <= 0 {
		return fmt.Errorf("user_id must be greater than 0")
	}

	if req.Published && strings.TrimSpace(req.Content) == "" {
		return fmt.Errorf("content cannot be empty when post is published")
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

// ScanRow scans database row into Post struct
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return fmt.Errorf("row is nil")
	}

	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// ScanPosts scans multiple database rows into Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, fmt.Errorf("rows is nil")
	}
	defer rows.Close()

	var posts []Post
	for rows.Next() {
		var post Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan post row: %v", err)
		}
		posts = append(posts, post)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating rows: %v", err)
	}

	return posts, nil
}
