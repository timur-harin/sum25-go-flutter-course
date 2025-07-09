package repository

import (
	"context"
	"database/sql"
	"fmt"

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
	// TODO: Create a new post in the database using scany for result mapping
	// - Validate the request using req.Validate()
	// - Insert into posts table with RETURNING clause
	// - Use sqlscan.Get() to scan the RETURNING result into a Post struct
	// Example: sqlscan.Get(context.Background(), r.db, &post, query, args...)
	// This eliminates manual row scanning compared to user repository
	err := req.Validate()
	if err != nil {
		return nil, err
	}
	query := `
		INSERT INTO posts (user_id, title, content, published)
		VALUES ($1, $2, $3, $4)
		RETURNING id, user_id, title, content, published, created_at, updated_at `

	var post models.Post
	err = sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		req.UserID,
		req.Title,
		req.Content,
		req.Published,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}

	return &post, nil
}

// TODO: Implement GetByID method using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	// TODO: Get post by ID from database using scany
	// - Use sqlscan.Get() instead of manual row.Scan()
	// Example: sqlscan.Get(context.Background(), r.db, &post, "SELECT * FROM posts WHERE id = $1", id)
	// Notice how this eliminates the need for manual field scanning
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE id = $1 `

	var post models.Post
	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		id,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post not found")
		}
		return nil, fmt.Errorf("failed to get post: %w", err)
	}

	return &post, nil
}

// TODO: Implement GetByUserID method using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	// TODO: Get all posts by user ID using scany
	// - Use sqlscan.Select() for multiple rows instead of manual rows.Next() loop
	// Example: sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	// This eliminates manual iteration and scanning
	query := `
		SELECT id, user_id, title, content, published, created_at, updated_at
		FROM posts
		WHERE user_id = $1
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

// TODO: Implement GetPublished method using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	// TODO: Get all published posts using scany
	// - Use sqlscan.Select() for multiple rows
	// - Query posts where published = true
	// - Order by created_at DESC
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

// TODO: Implement GetAll method using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	// TODO: Get all posts from database using scany
	// - Use sqlscan.Select() instead of manual rows iteration
	// Example: sqlscan.Select(context.Background(), r.db, &posts, "SELECT * FROM posts ORDER BY created_at DESC")
	// Compare this simplicity with manual scanning in user repository
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
		return nil, fmt.Errorf("failed to get all posts: %w", err)
	}

	return posts, nil
}

// TODO: Implement Update method using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	// TODO: Update post in database using scany
	// - Build dynamic UPDATE query based on non-nil fields in req
	// - Update updated_at timestamp
	// - Use sqlscan.Get() with RETURNING clause to get updated post
	// This avoids a separate SELECT query after UPDATE
	query := "UPDATE posts SET "
	args := make([]interface{}, 0)
	argPos := 1

	if req.Title != nil {
		query += fmt.Sprintf("title = $%d, ", argPos)
		args = append(args, *req.Title)
		argPos++
	}

	if req.Content != nil {
		query += fmt.Sprintf("content = $%d, ", argPos)
		args = append(args, *req.Content)
		argPos++
	}

	if req.Published != nil {
		query += fmt.Sprintf("published = $%d, ", argPos)
		args = append(args, *req.Published)
		argPos++
	}

	query += fmt.Sprintf("updated_at = CURRENT_TIMESTAMP WHERE id = $%d ", argPos)
	args = append(args, id)
	argPos++

	query += `
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`

	var post models.Post
	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		args...,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post not found")
		}
		return nil, fmt.Errorf("failed to update post: %w", err)
	}

	return &post, nil
}

// TODO: Implement Delete method (standard SQL)
func (r *PostRepository) Delete(id int) error {
	// TODO: Delete post from database
	// - Delete from posts table by ID
	// - Return error if post doesn't exist
	// Note: Delete operations typically don't need scany since no data is returned
	result, err := r.db.Exec(
		"DELETE FROM posts WHERE id = $1",
		id,
	)

	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return fmt.Errorf("post not found")
	}

	return nil
}

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	// TODO: Count total number of posts
	// - Return count of posts in database
	// - Can use standard QueryRow.Scan() for single values like count
	var count int
	err := r.db.QueryRow(
		"SELECT COUNT(*) FROM posts",
	).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}

	return count, nil
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	// TODO: Count posts by user ID
	// - Return count of posts for specific user
	// - Use standard QueryRow.Scan() for single integer result
	var count int
	err := r.db.QueryRow(
		"SELECT COUNT(*) FROM posts WHERE user_id = $1",
		userID,
	).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("failed to count user posts: %w", err)
	}
	return count, nil
}
