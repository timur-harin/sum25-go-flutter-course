// File: models/post.go
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

// UpdatePostRequest represents the payload for updating a post
type UpdatePostRequest struct {
    Title     *string `json:"title,omitempty"`
    Content   *string `json:"content,omitempty"`
    Published *bool   `json:"published,omitempty"`
}

// Validate performs basic sanity checks on an existing Post.
func (p *Post) Validate() error {
    if p.UserID <= 0 {
        return errors.New("user_id must be greater than 0")
    }
    if len(strings.TrimSpace(p.Title)) < 5 {
        return errors.New("title must be at least 5 characters long")
    }
    if p.Published && strings.TrimSpace(p.Content) == "" {
        return errors.New("content cannot be empty when post is published")
    }
    return nil
}

// Validate checks that the request payload is sensible before creating a Post.
func (req *CreatePostRequest) Validate() error {
    if req.UserID <= 0 {
        return errors.New("user_id must be greater than 0")
    }
    if len(strings.TrimSpace(req.Title)) < 5 {
        return errors.New("title must be at least 5 characters long")
    }
    if req.Published && strings.TrimSpace(req.Content) == "" {
        return errors.New("content cannot be empty when post is published")
    }
    return nil
}

// ToPost converts the CreatePostRequest into a Post and populates timestamps.
func (req *CreatePostRequest) ToPost() *Post {
    now := time.Now().UTC()
    return &Post{
        UserID:    req.UserID,
        Title:     strings.TrimSpace(req.Title),
        Content:   req.Content,
        Published: req.Published,
        CreatedAt: now,
        UpdatedAt: now,
    }
}

// ScanRow scans a single *sql.Row into the Post struct.
func (p *Post) ScanRow(row *sql.Row) error {
    if row == nil {
        return errors.New("row is nil")
    }
    return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// ScanPosts iterates over *sql.Rows and returns a slice of Post.
func ScanPosts(rows *sql.Rows) ([]Post, error) {
    if rows == nil {
        return nil, errors.New("rows is nil")
    }
    defer rows.Close()

    var posts []Post
    for rows.Next() {
        var p Post
        if err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt); err != nil {
            return nil, err
        }
        posts = append(posts, p)
    }
    if err := rows.Err(); err != nil {
        return nil, err
    }
    return posts, nil
}