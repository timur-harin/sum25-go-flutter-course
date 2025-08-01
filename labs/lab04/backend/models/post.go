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

// Validate checks if the Post fields meet the required criteria:
// - Title must be at least 5 characters long
// - Content must not be empty if post is published
// - UserID must be greater than 0
// Returns appropriate error if validation fails
func (p *Post) Validate() error {
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

// Validate checks if the CreatePostRequest fields meet the required criteria:
// - Title must be at least 5 characters long
// - UserID must be greater than 0
// - Content must not be empty if post is to be published
// Returns appropriate error if validation fails
func (req *CreatePostRequest) Validate() error {
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

// ToPost converts a CreatePostRequest into a Post struct
// Sets CreatedAt and UpdatedAt timestamps to current time
// Returns a pointer to the new Post
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

// ScanRow scans a database row into the Post struct fields
// Takes a *sql.Row as input and returns error if scan fails
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

// ScanPosts scans multiple database rows into a slice of Posts
// Takes *sql.Rows as input and returns the Post slice and error if scan fails
// Returns sql.ErrNoRows if rows is nil
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
