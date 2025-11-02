package models

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
	"unicode/utf8"
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
	if p.Title == "" {
		return ErrEmptyTitle
	} else if utf8.RuneCountInString(p.Title) < 5 {
		return ErrShortTitle
	}

	if p.Published == true && p.Content == "" {
		return ErrEmptyContentWithPublishedTrue
	}

	if p.UserID <= 0 {
		return ErrNegativeUserID
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
	if req.Title == "" {
		return ErrEmptyTitle
	} else if utf8.RuneCountInString(req.Title) < 5 {
		return ErrShortTitle
	}

	if req.Published == true && req.Content == "" {
		return ErrEmptyContentWithPublishedTrue
	}

	if req.UserID <= 0 {
		return ErrNegativeUserID
	}

	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
func (req *CreatePostRequest) ToPost() *Post {
	// TODO: Convert CreatePostRequest to Post
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

// TODO: Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	// TODO: Scan database row into Post struct
	// Handle the case where row might be nil
	err := row.Scan(
		&p.ID,
		&p.UserID,
		&p.Title,
		&p.Content,
		&p.Published,
		&p.CreatedAt,
		&p.UpdatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrEmptyRow
		}
		return fmt.Errorf("failed while scanning the row: %w", err)
	}

	return nil
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	// TODO: Scan multiple database rows into Post slice
	// Make sure to close rows and handle errors properly
	posts := make([]Post, 0)

	defer func() {
		if err := rows.Close(); err != nil {
			fmt.Printf("failed while closing the row: %s", err)
		}
	}()

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
			return nil, fmt.Errorf("failed while scanning rows: %w", err)
		}

		posts = append(posts, post)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("error during rows iteration: %w", err)
	}

	return posts, nil
}

var (
	ErrEmptyTitle                    = errors.New("title cannot be empty")
	ErrShortTitle                    = errors.New("Title should be at least 5 characters long")
	ErrEmptyContentWithPublishedTrue = errors.New("content should not be empty if published is true")
	ErrNegativeUserID                = errors.New("user id cannot be empty")
)
