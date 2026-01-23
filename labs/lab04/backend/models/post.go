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

// Implementation of Validate method for Post
func (post *Post) Validate() error {
	if post.UserID <= 0 {
		return fmt.Errorf("user ID must be positive")
	}
	if len(post.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters")
	}
	if post.Published && post.Content == "" {
		return fmt.Errorf("content cannot be empty when published")
	}
	return nil
}

// Implementation of Validate method for CreatePostRequest
func (request *CreatePostRequest) Validate() error {
	if request.UserID <= 0 {
		return fmt.Errorf("user ID must be positive")
	}
	if len(request.Title) < 5 {
		return fmt.Errorf("title must be at least 5 characters")
	}
	if request.Published && len(request.Content) == 0 {
		return fmt.Errorf("content cannot be empty when published")
	}
	return nil
}

// Implementation of ToPost method for CreatePostRequest
func (request *CreatePostRequest) ToPost() *Post {
	return &Post{
		UserID:    request.UserID,
		Title:     request.Title,
		Content:   request.Content,
		Published: request.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

// Implementation of ScanRow method for Post
func (post *Post) ScanRow(row *sql.Row) error {
	err := row.Scan(&post.ID,
		&post.UserID,
		&post.Title,
		&post.Content,
		&post.Published,
		&post.CreatedAt,
		&post.UpdatedAt)

	if err != nil {
		return err
	}

	return nil
}

// Implementation of ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	for rows.Next() {
		var post Post
		err := rows.Scan(&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Published,
			&post.CreatedAt,
			&post.UpdatedAt)

		if err != nil {
			return nil, err
		}

		posts = append(posts, post)
	}
	rows.Close()
	return posts, nil
}
