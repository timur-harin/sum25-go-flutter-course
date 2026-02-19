package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"

	"github.com/georgysavva/scany/v2/sqlscan"
)

// PostRepository handles database operations for posts
// This repository demonstrates SCANY MAPPING approach for result scanning
type PostRepository struct {
	db *sql.DB
}

// NewPostRepository creates a new PostRepository
func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

// Create creates a new post in the database using scany for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %v", err)
	}
	post := req.ToPost()
	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES (?, ?, ?, ?, ?, ?)
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`
	ctx := context.Background()
	if err := sqlscan.Get(ctx, r.db, post, query, post.UserID, post.Title, post.Content, post.Published, post.CreatedAt, post.UpdatedAt); err != nil {
		return nil, fmt.Errorf("failed to create post: %v", err)
	}
	return post, nil
}

// GetByID gets post by ID from database using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE id = ? AND deleted_at IS NULL
	`
	var post models.Post
	ctx := context.Background()
	if err := sqlscan.Get(ctx, r.db, &post, query, id); err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get post by ID: %v", err)
	}
	return &post, nil
}

// GetByUserID gets all posts by user ID using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE user_id = ? AND deleted_at IS NULL
		ORDER BY created_at DESC
	`
	var posts []models.Post
	ctx := context.Background()
	if err := sqlscan.Select(ctx, r.db, &posts, query, userID); err != nil {
		return nil, fmt.Errorf("failed to get posts by user ID: %v", err)
	}
	return posts, nil
}

// GetPublished gets all published posts using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE published = 1 AND deleted_at IS NULL
		ORDER BY created_at DESC
	`
	var posts []models.Post
	ctx := context.Background()
	if err := sqlscan.Select(ctx, r.db, &posts, query); err != nil {
		return nil, fmt.Errorf("failed to get published posts: %v", err)
	}
	return posts, nil
}

// GetAll gets all posts from database using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE deleted_at IS NULL
		ORDER BY created_at DESC
	`
	var posts []models.Post
	ctx := context.Background()
	if err := sqlscan.Select(ctx, r.db, &posts, query); err != nil {
		return nil, fmt.Errorf("failed to get all posts: %v", err)
	}
	return posts, nil
}

// Update updates post in database using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	// Build dynamic UPDATE query
	var setParts []string
	var args []interface{}
	if req.Title != nil {
		setParts = append(setParts, "title = ?")
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		setParts = append(setParts, "content = ?")
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		setParts = append(setParts, "published = ?")
		args = append(args, *req.Published)
	}
	if len(setParts) == 0 {
		return r.GetByID(id) // No changes
	}
	setParts = append(setParts, "updated_at = ?")
	args = append(args, time.Now())
	args = append(args, id)
	query := fmt.Sprintf(`
		UPDATE posts
		SET %s
		WHERE id = ? AND deleted_at IS NULL
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`, strings.Join(setParts, ", "))
	var post models.Post
	ctx := context.Background()
	if err := sqlscan.Get(ctx, r.db, &post, query, args...); err != nil {
		return nil, fmt.Errorf("failed to update post: %v", err)
	}
	return &post, nil
}

// Delete deletes post from database
func (r *PostRepository) Delete(id int) error {
	query := `
		UPDATE posts
		SET deleted_at = ?
		WHERE id = ? AND deleted_at IS NULL
	`
	result, err := r.db.Exec(query, time.Now(), id)
	if err != nil {
		return fmt.Errorf("failed to delete post: %v", err)
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get rows affected: %v", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Count counts total number of posts
func (r *PostRepository) Count() (int, error) {
	query := `
		SELECT COUNT(*) FROM posts WHERE deleted_at IS NULL
	`
	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %v", err)
	}
	return count, nil
}

// CountByUserID counts posts by user ID
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	query := `
		SELECT COUNT(*) FROM posts WHERE user_id = ? AND deleted_at IS NULL
	`
	var count int
	err := r.db.QueryRow(query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts by user: %v", err)
	}
	return count, nil
}
