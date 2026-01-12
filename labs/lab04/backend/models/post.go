package models

import (
	"database/sql"
	"errors"
	"strings"
	"time"
)

type Post struct {
	ID        int       `json:"id" db:"id"`
	UserID    int       `json:"user_id" db:"user_id"`
	Title     string    `json:"title" db:"title"`
	Content   string    `json:"content" db:"content"`
	Published bool      `json:"published" db:"published"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

type CreatePostRequest struct {
	UserID    int    `json:"user_id"`
	Title     string `json:"title"`
	Content   string `json:"content"`
	Published bool   `json:"published"`
}

// type UpdatePostRequest struct {
// 	Title     *string `json:"title,omitempty"`
// 	Content   *string `json:"content,omitempty"`
// 	Published *bool   `json:"published,omitempty"`
// }

func (p *Post) Validate() error {
	if len(strings.TrimSpace(p.Title)) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if p.Published && len(strings.TrimSpace(p.Content)) == 0 {
		return errors.New("content is required if published")
	}
	if p.UserID <= 0 {
		return errors.New("user_id must be positive")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(strings.TrimSpace(req.Title)) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if req.Published && len(strings.TrimSpace(req.Content)) == 0 {
		return errors.New("content is required if published")
	}
	if req.UserID <= 0 {
		return errors.New("user_id must be positive")
	}
	return nil
}

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

func (p *Post) ScanRow(row *sql.Row) error {
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	for rows.Next() {
		var p Post
		err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	return posts, rows.Err()
}
