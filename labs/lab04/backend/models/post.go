// models/post.go
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
	
	User       *User        `json:"user,omitempty" db:"-"`
	Categories []*Category  `json:"categories,omitempty" db:"-" gorm:"many2many:post_categories;"`
}

// Остальной код остается без изменений

type CreatePostRequest struct {
	UserID    int    `json:"user_id" validate:"required,gt=0"`
	Title     string `json:"title" validate:"required,min=5"`
	Content   string `json:"content" validate:"required"`
	Published bool   `json:"published"`
}

type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty" validate:"omitempty,min=5"`
	Content   *string `json:"content,omitempty" validate:"omitempty"`
	Published *bool   `json:"published,omitempty"`
}

func (p *Post) Validate() error {
	if p.Title == "" || len(p.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if p.Content == "" {
		return errors.New("content is required")
	}
	if p.UserID <= 0 {
		return errors.New("invalid user ID")
	}
	if p.Published && p.Content == "" {
		return errors.New("content cannot be empty when published")
	}
	return nil
}

func (req *CreatePostRequest) Validate() error {
	if req.Title == "" || len(req.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	if req.Content == "" {
		return errors.New("content is required")
	}
	if req.UserID <= 0 {
		return errors.New("invalid user ID")
	}
	return nil
}

func (req *UpdatePostRequest) Validate() error {
	if req.Title != nil && len(*req.Title) < 5 {
		return errors.New("title must be at least 5 characters")
	}
	return nil
}

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

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	var posts []Post
	defer rows.Close()

	for rows.Next() {
		var p Post
		err := rows.Scan(
			&p.ID,
			&p.UserID,
			&p.Title,
			&p.Content,
			&p.Published,
			&p.CreatedAt,
			&p.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, p)
	}

	return posts, nil
}