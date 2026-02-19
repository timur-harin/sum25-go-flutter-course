package models

import (
	"database/sql"
	"errors"
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

// TODO: Implement Validate method for Post
func (p *Post) Validate() error {
	if p.UserID <= 0 {
		return errors.New("user_id должен быть больше 0")
	}
	if len(p.Title) < 5 {
		return errors.New("заголовок должен содержать минимум 5 символов")
	}
	if p.Published && len(p.Content) == 0 {
		return errors.New("контент не может быть пустым для опубликованного поста")
	}
	return nil
}

// TODO: Implement Validate method for CreatePostRequest
func (req *CreatePostRequest) Validate() error {
	if req.UserID <= 0 {
		return errors.New("user_id должен быть больше 0")
	}
	if len(req.Title) < 5 {
		return errors.New("заголовок должен содержать минимум 5 символов")
	}
	if req.Published && len(req.Content) == 0 {
		return errors.New("контент не может быть пустым для опубликованного поста")
	}
	return nil
}

// TODO: Implement ToPost method for CreatePostRequest
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

// TODO: Implement ScanRow method for Post
func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row is nil")
	}
	return row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
}

// TODO: Implement ScanRows method for Post slice
func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, errors.New("rows is nil")
	}
	defer rows.Close()
	var posts []Post
	for rows.Next() {
		var p Post
		err := rows.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return posts, nil
}
