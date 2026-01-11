package models

import (
	"database/sql"
	"errors"
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

type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty"`
	Content   *string `json:"content,omitempty"`
	Published *bool   `json:"published,omitempty"`
}

func (p *Post) Validate() error {
	if p.Title == "" || len(p.Title) < 5 {
		return errors.New("title requires at least 5 characters")
	}
	if p.Published && p.Content == "" {
		return errors.New("content must be provided for published posts")
	}
	if p.UserID <= 0 {
		return errors.New("user_id must be a positive integer")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if req.Title == "" || len(req.Title) < 5 {
		return errors.New("title must have 5 or more characters")
	}
	if req.Published && req.Content == "" {
		return errors.New("published posts require non-empty content")
	}
	if req.UserID <= 0 {
		return errors.New("user_id should be greater than zero")
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	currentTime := time.Now()
	post := &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: currentTime,
		UpdatedAt: currentTime,
	}
	return post
}

func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("nil row provided")
	}
	err := row.Scan(&p.ID, &p.UserID, &p.Title, &p.Content, &p.Published, &p.CreatedAt, &p.UpdatedAt)
	return err
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var postList []Post
	defer rows.Close()
	for rows.Next() {
		post := Post{}
		if scanErr := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt); scanErr != nil {
			return nil, scanErr
		}
		postList = append(postList, post)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return postList, nil
}