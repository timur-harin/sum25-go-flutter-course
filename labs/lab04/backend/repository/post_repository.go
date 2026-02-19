package repository

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"lab04-backend/models"

	"github.com/georgysavva/scany/v2/sqlscan"
)

// PostRepository handles database operations for posts
type PostRepository struct {
	db *sql.DB
}

// NewPostRepository creates a new PostRepository
func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

// Create creates a new post in the database
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	post := req.ToPost()

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?)
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`

	var createdPost models.Post
	err := sqlscan.Get(
		context.Background(),
		r.db,
		&createdPost,
		query,
		post.UserID,
		post.Title,
		post.Content,
		post.Published,
		post.CreatedAt,
		post.UpdatedAt,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}

	return &createdPost, nil
}

// GetByID gets a post by ID from the database
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE id = ?
	`

	var post models.Post
	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		id,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("post not found")
		}
		return nil, fmt.Errorf("failed to get post: %w", err)
	}

	return &post, nil
}

// GetByUserID gets all posts by user ID from the database
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE user_id = ?
		ORDER BY created_at DESC
	`

	var posts []models.Post
	err := sqlscan.Select(
		context.Background(),
		r.db,
		&posts,
		query,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get posts: %w", err)
	}

	return posts, nil
}

// GetPublished gets all published posts from the database
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE published = true
		ORDER BY created_at DESC
	`

	var posts []models.Post
	err := sqlscan.Select(
		context.Background(),
		r.db,
		&posts,
		query,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get published posts: %w", err)
	}

	return posts, nil
}

// GetAll gets all posts from the database
func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		ORDER BY created_at DESC
	`

	var posts []models.Post
	err := sqlscan.Select(
		context.Background(),
		r.db,
		&posts,
		query,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get posts: %w", err)
	}

	return posts, nil
}

// Update updates a post in the database
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	// Start with base query
	query := `
		UPDATE posts
		SET updated_at = ?
	`
	args := []interface{}{time.Now()}

	// Add fields to update if they are not nil
	if req.Title != nil {
		query += ", title = ?"
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		query += ", content = ?"
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		query += ", published = ?"
		args = append(args, *req.Published)
	}

	// Add WHERE clause and RETURNING
	query += " WHERE id = ? RETURNING id, user_id, title, content, published, created_at, updated_at"
	args = append(args, id)

	var updatedPost models.Post
	err := sqlscan.Get(
		context.Background(),
		r.db,
		&updatedPost,
		query,
		args...,
	)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, fmt.Errorf("post not found")
		}
		return nil, fmt.Errorf("failed to update post: %w", err)
	}

	return &updatedPost, nil
}

// Delete deletes a post from the database
func (r *PostRepository) Delete(id int) error {
	result, err := r.db.ExecContext(context.Background(), "DELETE FROM posts WHERE id = ?", id)
	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("post not found")
	}

	return nil
}

// Count counts the total number of posts in the database
func (r *PostRepository) Count() (int, error) {
	var count int
	row := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts")
	if err := row.Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}
	return count, nil
}

// CountByUserID counts the number of posts by user ID
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	row := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts WHERE user_id = ?", userID)
	if err := row.Scan(&count); err != nil {
		return 0, fmt.Errorf("failed to count posts by user: %w", err)
	}
	return count, nil
}
