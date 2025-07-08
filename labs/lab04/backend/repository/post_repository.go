package repository

import (
	"context"
	"database/sql"
	"fmt"
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
		return nil, err
	}

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING *;
	`

	now := time.Now()
	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, query,
		req.UserID, req.Title, req.Content, req.Published, now, now,
	)
	return post, err
}

// GetByID gets post by ID from database using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, "SELECT * FROM posts WHERE id = $1", id)
	return post, err
}

// GetByUserID gets all posts by user ID using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC", userID)
	return posts, err
}

// GetPublished gets all published posts using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts WHERE published = true ORDER BY created_at DESC")
	return posts, err
}

// GetAll gets all posts from database using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts ORDER BY created_at DESC")
	return posts, err
}

// Update updates post in database using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	query := `
		UPDATE posts
		SET title = COALESCE($1, title),
			content = COALESCE($2, content),
			published = COALESCE($3, published),
			updated_at = $4
		WHERE id = $5
		RETURNING *;
	`

	now := time.Now()
	post := &models.Post{}
	err := sqlscan.Get(context.Background(), r.db, post, query,
		req.Title, req.Content, req.Published, now, id)
	return post, err
}

// Delete deletes post from database
func (r *PostRepository) Delete(id int) error {
	result, err := r.db.Exec("DELETE FROM posts WHERE id = $1", id)
	if err != nil {
		return err
	}
	rows, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rows == 0 {
		return fmt.Errorf("post with ID %d not found", id)
	}
	return nil
}

// Count returns total number of posts
func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts").Scan(&count)
	return count, err
}

// CountByUserID returns count of posts for specific user
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts WHERE user_id = $1", userID).Scan(&count)
	return count, err
}
