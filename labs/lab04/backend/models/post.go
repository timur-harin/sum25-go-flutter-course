package models

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/go-playground/validator/v10"
)

func validatePublishedContent(fl validator.FieldLevel) bool {
	post, ok := fl.Parent().Interface().(Post)
	if !ok { return false }
	return !post.Published || post.Published && post.Content != ""
}

// Post represents a blog post in the system
type Post struct {
	ID        int       `json:"id" db:"id"`
	UserID    int       `json:"user_id" db:"user_id" validate:"required,min=1"`
	Title     string    `json:"title" db:"title" validate:"required,min=5"`
	Content   string    `json:"content" db:"content" validate:"required_if_published"`
	Published bool      `json:"published" db:"published"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreatePostRequest represents the payload for creating a post
type CreatePostRequest struct {
	UserID    int    `json:"user_id" validate:"required,min=1"`
	Title     string `json:"title" validate:"required,min=5"`
	Content   string `json:"content" validate:"required_if_published"`
	Published bool   `json:"published"`
}

// UpdatePostRequest represents the payload for updating a post
type UpdatePostRequest struct {
	Title     *string `json:"title,omitempty" validate:"min=5"`
	Content   *string `json:"content,omitempty" validate:"required_if_published"`
	Published *bool   `json:"published,omitempty"`
}

func (p *Post) Validate() error {
	return validate.Struct(p)
}

func (req *CreatePostRequest) Validate() error {
	return validate.Struct(req)
}

func (req *CreatePostRequest) ToPost() *Post {
	return &Post{
		UserID: req.UserID,
		Title: req.Title,
		Content: req.Content,
		Published: req.Published,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
}

func (p *Post) ScanRow(row *sql.Row) error {
	if row == nil {
		return errNilRow
	}
	err := row.Scan(
		&p.ID, &p.UserID, &p.Title, &p.Content,
		&p.CreatedAt, &p.UpdatedAt,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return fmt.Errorf("user not found: %w", err)
		}
		return err
	}
	return nil
}

func ScanPosts(rows *sql.Rows) ([]Post, error) {
	if rows == nil {
		return nil, errNilRows
	}
	defer rows.Close()
	
	var posts []Post
	
	for rows.Next() {
		var user Post
		err := rows.Scan(
			&user.ID,
			&user.Title,
			&user.Content,
			&user.CreatedAt,
			&user.UpdatedAt,
		)
		if err != nil {
			return nil, err
		}
		posts = append(posts, user)
	}
	
	if err := rows.Err(); err != nil {
		return nil, err
	}
	
	return posts, nil
}
