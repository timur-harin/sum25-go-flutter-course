package models

import (
	"database/sql"
	"errors"
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

// UpdatePostRequest должен быть определен
type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty"`
	Content   *string `json:"content,omitempty"`
	Published *bool   `json:"published,omitempty"`
}

// Validate validates the Post fields
func (p *Post) Validate() error {
	if p.UserID <= 0 {
		return errors.New("user ID must be positive")
	}
	if strings.TrimSpace(p.Title) == "" {
		return errors.New("title cannot be empty")
	}
	if len(p.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if p.Published && strings.TrimSpace(p.Content) == "" {
		return errors.New("content cannot be empty for published posts")
	}
	return nil
}

// Validate validates the CreatePostRequest fields
func (req *CreatePostRequest) Validate() error {
	if req.UserID <= 0 {
		return errors.New("user ID must be positive")
	}
	if strings.TrimSpace(req.Title) == "" {
		return errors.New("title cannot be empty")
	}
	if len(req.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if req.Published && strings.TrimSpace(req.Content) == "" {
		return errors.New("content cannot be empty for published posts")
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

// ScanRow scans a database row into the Post struct
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return sql.ErrNoRows
	}
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// ScanPosts scans multiple rows into a slice of Posts
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	defer rows.Close()

	for rows.Next() {
		var post Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
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
