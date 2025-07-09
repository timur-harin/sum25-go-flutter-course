package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/georgysavva/scany/sqlscan"
	"lab04-backend/models"
)

// PostRepository handles database operations for posts
type PostRepository struct {
	db *sql.DB
}

func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	post := req.ToPost()
	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id
	`

	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post.ID,
		query,
		post.UserID, post.Title, post.Content, post.Published, post.CreatedAt, post.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}
	return post, nil
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	var post models.Post
	query := `SELECT * FROM posts WHERE id = $1`

	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		id,
	)

	if err != nil {
		if sqlscan.NotFound(err) {
			return nil, fmt.Errorf("post not found: %w", err)
		}
		return nil, fmt.Errorf("failed to get post: %w", err)
	}
	return &post, nil
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	query := `
		SELECT * FROM posts 
		WHERE user_id = $1 
		ORDER BY created_at DESC
	`

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

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	query := `
		SELECT * FROM posts 
		WHERE published = true 
		ORDER BY created_at DESC
	`

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

func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	query := `SELECT * FROM posts ORDER BY created_at DESC`

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

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	var post models.Post
	var args []interface{}
	args = append(args, time.Now()) // updated_at
	query := "UPDATE posts SET updated_at = $1"

	argPos := 2
	if req.Title != nil {
		query += fmt.Sprintf(", title = $%d", argPos)
		args = append(args, *req.Title)
		argPos++
	}
	if req.Content != nil {
		query += fmt.Sprintf(", content = $%d", argPos)
		args = append(args, *req.Content)
		argPos++
	}
	if req.Published != nil {
		query += fmt.Sprintf(", published = $%d", argPos)
		args = append(args, *req.Published)
		argPos++
	}

	query += fmt.Sprintf(" WHERE id = $%d RETURNING *", argPos)
	args = append(args, id)

	err := sqlscan.Get(
		context.Background(),
		r.db,
		&post,
		query,
		args...,
	)

	if err != nil {
		if sqlscan.NotFound(err) {
			return nil, fmt.Errorf("post not found: %w", err)
		}
		return nil, fmt.Errorf("failed to update post: %w", err)
	}
	return &post, nil
}

func (r *PostRepository) Delete(id int) error {
	res, err := r.db.Exec(
		`DELETE FROM posts WHERE id = $1`,
		id,
	)
	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}

	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check delete result: %w", err)
	}
	if rowsAffected == 0 {
		return fmt.Errorf("post not found")
	}
	return nil
}

func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow(
		`SELECT COUNT(*) FROM posts`,
	).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}
	return count, nil
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow(
		`SELECT COUNT(*) FROM posts WHERE user_id = $1`,
		userID,
	).Scan(&count)

	if err != nil {
		return 0, fmt.Errorf("failed to count user posts: %w", err)
	}
	return count, nil
}
