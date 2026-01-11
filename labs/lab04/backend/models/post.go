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

func (p *Post) Validate() error {
	if len(p.Title) < 5 {
		return errors.New("Title should not be empty and should be at least 5 characters")
	} else if p.Published && p.Content == "" {
		return errors.New("Content should not be empty if published is true")
	} else if p.UserID <= 0 {
		return errors.New("UserID should be greater than 0")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(req.Title) < 5 {
		return errors.New("Title should not be empty and should be at least 5 characters")
	} else if req.UserID <= 0 {
		return errors.New("UserID should be greater than 0")
	} else if req.Published && req.Content == "" {
		return errors.New("UserID should be greater than 0")
	} else {
		return nil
	}
}

func (req *CreatePostRequest) ToPost() *Post {
	post := &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	return post
}

func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("nil row")
	}
	err := row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
	return err
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	defer rows.Close()
	var posts []Post
	if rows == nil {
		return nil, errors.New("nil row")
	}
	for rows.Next() {
		var p Post
		err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			return nil, fmt.Errorf("failed to scan row: %w", err)
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %w", err)
	}
	return posts, nil
}
