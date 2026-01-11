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

type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty"`
	Content   *string `json:"content,omitempty"`
	Published *bool   `json:"published,omitempty"`
}

func (p *Post) Validate() error {
	if len(strings.TrimSpace(p.Title)) == 0 || len(p.Title) < 5 {
		return errors.New("title should not be empty and should be at least 5 characters")
	}

	if p.Published && len(strings.TrimSpace(p.Content)) == 0 {
		return errors.New("content should not be empty if published is true")
	}

	if p.UserID <= 0 {
		return errors.New("user ID should be greater than 0")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if len(strings.TrimSpace(req.Title)) == 0 || len(req.Title) < 5 {
		return errors.New("title should not be empty and should be at least 5 characters")
	}

	if req.Published && len(strings.TrimSpace(req.Content)) == 0 {
		return errors.New("content should not be empty if published is true")
	}

	if req.UserID <= 0 {
		return errors.New("user ID should be greater than 0")
	}
	return nil
}

func (req *CreatePostRequest) ToPost() *Post {
	time := time.Now()
	return &Post{
		UserID:    req.UserID,
		Title:     req.Title,
		Content:   req.Content,
		Published: req.Published,
		CreatedAt: time,
		UpdatedAt: time,
	}
}

func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errors.New("row value is nil")
	}
	return row.Scan(
		&p.ID,
		&p.UserID,
		&p.Title, &p.Content,
		&p.Published,
		&p.CreatedAt,
		&p.UpdatedAt,
	)
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, errors.New("rows value is nil")
	}
	defer rows.Close() // ensures the database result set (rows) is closed at the end of the function
	var posts []Post

	for rows.Next() {
		var post Post     // maps the columns from the current row into the fields of post
		err := rows.Scan( // uses pointers & so the values get written directly into the struct fields.
			&post.ID,
			&post.UserID,
			&post.Title,
			&post.Content,
			&post.Published,
			&post.CreatedAt,
			&post.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	if err := rows.Err(); err != nil { // ensures the row iteration didn't end due to a hidden error
		return nil, err
	}

	return posts, nil
}
