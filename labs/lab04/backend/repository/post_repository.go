package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"lab04-backend/models"

	"github.com/georgysavva/scany/sqlscan"
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

// TODO: Implement Create method using scany for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`

	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, query,
		req.UserID, req.Title, req.Content, req.Published)
	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}

	return post, nil
}

// TODO: Implement GetByID method using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE id = $1
	`

	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post with id %d not found", id)
		}
		return nil, fmt.Errorf("failed to get post: %w", err)
	}

	return post, nil
}

// TODO: Implement GetByUserID method using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE user_id = $1
		ORDER BY created_at DESC
	`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get posts by user id %d: %w", userID, err)
	}
	return posts, nil
}

// TODO: Implement GetPublished method using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE published = TRUE
		ORDER BY created_at DESC
	`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get published posts: %w", err)
	}
	return posts, nil
}

// TODO: Implement GetAll method using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		ORDER BY created_at DESC
	`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all posts: %w", err)
	}
	return posts, nil
}

// TODO: Implement Update method using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	setParts := []string{}
	args := []interface{}{}
	argPos := 1

	if req.Title != nil {
		setParts = append(setParts, fmt.Sprintf("title = $%d", argPos))
		args = append(args, *req.Title)
		argPos++
	}
	if req.Content != nil {
		setParts = append(setParts, fmt.Sprintf("content = $%d", argPos))
		args = append(args, *req.Content)
		argPos++
	}
	if req.Published != nil {
		setParts = append(setParts, fmt.Sprintf("published = $%d", argPos))
		args = append(args, *req.Published)
		argPos++
	}

	if len(setParts) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	setParts = append(setParts, fmt.Sprintf("updated_at = NOW()"))

	query := fmt.Sprintf(`
		UPDATE posts
		SET %s
		WHERE id = $%d
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`, strings.Join(setParts, ", "), argPos)

	args = append(args, id)

	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, query, args...)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post with id %d not found", id)
		}
		return nil, fmt.Errorf("failed to update post: %w", err)
	}

	return post, nil
}

// TODO: Implement Delete method (standard SQL)
func (r *PostRepository) Delete(id int) error {
	res, err := r.db.ExecContext(context.Background(), "DELETE FROM posts WHERE id = $1", id)
	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to get affected rows count: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("post with id %d not found", id)
	}
	return nil
}

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts").Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}
	return count, nil
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts WHERE user_id = $1", userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts by user id %d: %w", userID, err)
	}
	return count, nil
}
