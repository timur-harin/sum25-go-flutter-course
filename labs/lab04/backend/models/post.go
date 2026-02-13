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

func defaultPostValidate(
	title string,
	published bool,
	content string,
	id int) error {

	// Default values for a validation
	const minTitleLength int = 5
	const minID int = 1

	// Check the title
	if len(title) < minTitleLength {
		return fmt.Errorf("invalid title: %s", title)
	}

	if published {
		// Check the content
		if len(content) == 0 {
			return fmt.Errorf("empty content")
		}
	}

	// Check the ID
	if id < minID {
		return fmt.Errorf("invalid ID: %d", id)
	}

	return nil // OK - no error
}

// Validates the Post
func (p *Post) Validate() error {
	return defaultPostValidate(p.Title, p.Published, p.Content, p.UserID)
}

// Validates the CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	return defaultPostValidate(req.Title,
		req.Published,
		req.Content,
		req.UserID)
}

// Transforms CreatePostRequest to Post
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

// Scans a sql.Row to the Post
func (p *Post) ScanRow(row *sql.Row) error {
	// Check the row
	if row == nil {
		return errors.New("invalid row: nil")
	}

	return row.Scan(
		&p.ID,
		&p.UserID,
		&p.Title,
		&p.Content,
		&p.Published,
		&p.CreatedAt,
		&p.UpdatedAt)
}

// Scans a sql.Rows to a Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// Check the rows
	if rows == nil {
		return nil, errors.New("invalid rows: nil")
	}

	defer rows.Close()

	// Scan the rows
	var res []Post
	for rows.Next() {
		var post Post

		// Scan the post
		rows.Scan(
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Published,
			&post.CreatedAt,
			&post.UpdatedAt)

		// Add to the result slice
		res = append(res, post)
	}

	return res, rows.Err()
}
