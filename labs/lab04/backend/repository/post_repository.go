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

// Create inserts a new post with RETURNING mapping via sqlscan
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	// Validate request
	if err := req.Validate(); err != nil {
		return nil, err
	}

	// Prepare INSERT with RETURNING
	query := `
INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
VALUES ($1, $2, $3, $4, NOW(), NOW())
RETURNING id, user_id, title, content, published, created_at, updated_at
`
	// Execute and scan
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query,
		req.UserID, req.Title, req.Content, req.Published,
	)
	if err != nil {
		return nil, err
	}
	return &post, nil
}

// GetByID retrieves a post by ID using sqlscan
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at
FROM posts WHERE id = $1`
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, id)
	if err != nil {
		return nil, err
	}
	return &post, nil
}

// GetByUserID returns all posts for a given user
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at
FROM posts WHERE user_id = $1 ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// GetPublished returns published posts ordered by creation date
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at
FROM posts WHERE published = true ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// GetAll retrieves all posts ordered by created_at descending
func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at
FROM posts ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// Update applies non-nil fields and returns updated post via RETURNING
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	// Build dynamic SET clauses
	setClauses := []string{"updated_at = NOW()"}
	args := []interface{}{}
	if req.Title != nil {
		setClauses = append(setClauses, "title = $"+fmt.Sprint(len(args)+1))
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		setClauses = append(setClauses, "content = $"+fmt.Sprint(len(args)+1))
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		setClauses = append(setClauses, "published = $"+fmt.Sprint(len(args)+1))
		args = append(args, *req.Published)
	}
	if len(args) == 0 {
		// Nothing to update
		return r.GetByID(id)
	}
	// Append id
	args = append(args, id)

	// Construct query
	query := fmt.Sprintf(`
UPDATE posts SET %s
WHERE id = $%d
RETURNING id, user_id, title, content, published, created_at, updated_at
`,
		strings.Join(setClauses, ", "), len(args))

	// Execute and scan
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	if err != nil {
		return nil, err
	}
	return &post, nil
}

// Delete removes a post by ID, returns sql.ErrNoRows if none
func (r *PostRepository) Delete(id int) error {
	result, err := r.db.ExecContext(context.Background(),
		"DELETE FROM posts WHERE id = $1", id)
	if err != nil {
		return err
	}
	n, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if n == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// Count returns total number of posts
func (r *PostRepository) Count() (int, error) {
	var cnt int
	err := r.db.QueryRowContext(context.Background(),
		"SELECT COUNT(*) FROM posts").Scan(&cnt)
	return cnt, err
}

// CountByUserID returns number of posts for specific user
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var cnt int
	err := r.db.QueryRowContext(context.Background(),
		"SELECT COUNT(*) FROM posts WHERE user_id = $1", userID).Scan(&cnt)
	return cnt, err
}
