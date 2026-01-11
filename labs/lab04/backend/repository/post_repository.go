package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

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

// TODO: Implement Create method using scany for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed %w", err)
	}

	query := `
	INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
	VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
	RETURNING id, user_id, title, content, published, created_at, updated_at
	`

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, req.UserID, req.Title, req.Content, req.Published)
	if err != nil {
		return nil, fmt.Errorf("failed to insert post: %w", err)
	}

	return &post, nil
}

// TODO: Implement GetByID method using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `SELECT * FROM posts WHERE id = $1`

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, id)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("failed to get post by ID: %w", err)
	}
	return &post, nil
}

// TODO: Implement GetByUserID method using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get posts by user ID: %w", err)
	}

	return posts, nil
}

// TODO: Implement GetPublished method using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `SELECT * FROM posts WHERE published = TRUE ORDER BY created_at DESC`

	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get published posts: %w", err)
	}
	return posts, nil
}

// TODO: Implement GetAll method using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `SELECT * FROM posts ORDER BY created_at DESC`

	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all posts: %w", err)
	}
	return posts, nil
}

// TODO: Implement Update method using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	setClauses := []string{}
	args := []interface{}{}
	argID := 1

	if req.Title != nil {
		setClauses = append(setClauses, fmt.Sprintf("title = $%d", argID))
		args = append(args, *req.Title)
		argID++
	}
	if req.Content != nil {
		setClauses = append(setClauses, fmt.Sprintf("content = $%d", argID))
		args = append(args, *req.Content)
		argID++
	}
	if req.Published != nil {
		setClauses = append(setClauses, fmt.Sprintf("published = $%d", argID))
		args = append(args, *req.Published)
		argID++
	}
	if len(setClauses) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")

	query := fmt.Sprintf(`
		UPDATE posts
		SET %s
		WHERE id = $%d
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`,
		strings.Join(setClauses, ", "),
		argID,
	)
	args = append(args, id)

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to update post: %w", err)
	}
	return &post, nil
}

// TODO: Implement Delete method (standard SQL)
func (r *PostRepository) Delete(id int) error {
	query := `DELETE FROM posts WHERE id = $1`

	res, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}
	if rows == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	query := `SELECT COUNT(*) FROM posts`

	var count int
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}
	return count, nil
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	query := `SELECT COUNT(*) FROM posts WHERE user_id = $1`

	var count int
	err := r.db.QueryRow(query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count user posts: %w", err)
	}
	return count, nil
}
