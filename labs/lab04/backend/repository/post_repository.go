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

	postToCreate := req.ToPost()

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING *`

	var newPost models.Post
	err := sqlscan.Get(context.Background(), r.db, &newPost, query,
		postToCreate.UserID,
		postToCreate.Title,
		postToCreate.Content,
		postToCreate.Published,
		postToCreate.CreatedAt,
		postToCreate.UpdatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}

	return &newPost, nil
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := "SELECT * FROM posts WHERE id = $1"
	var post models.Post

	err := sqlscan.Get(context.Background(), r.db, &post, query, id)
	if err != nil {
		if sqlscan.NotFound(err) {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to get post by id: %w", err)
	}

	return &post, nil
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := "SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC"
	var posts []models.Post

	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get posts by user id: %w", err)
	}

	return posts, nil
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := "SELECT * FROM posts WHERE published = TRUE ORDER BY created_at DESC"
	var posts []models.Post

	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get published posts: %w", err)
	}

	return posts, nil
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := "SELECT * FROM posts ORDER BY created_at DESC"
	var posts []models.Post

	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, fmt.Errorf("failed to get all posts: %w", err)
	}

	return posts, nil
}

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	var setClauses []string
	var args []interface{}
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
		return r.GetByID(id)
	}

	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argID))
	args = append(args, time.Now().UTC())
	argID++

	query := fmt.Sprintf("UPDATE posts SET %s WHERE id = $%d RETURNING *",
		strings.Join(setClauses, ", "), argID)
	args = append(args, id)

	var updatedPost models.Post
	err := sqlscan.Get(context.Background(), r.db, &updatedPost, query, args...)
	if err != nil {
		if sqlscan.NotFound(err) {
			return nil, sql.ErrNoRows
		}
		return nil, fmt.Errorf("failed to update post: %w", err)
	}

	return &updatedPost, nil
}

func (r *PostRepository) Delete(id int) error {
	query := "DELETE FROM posts WHERE id = $1"
	result, err := r.db.Exec(query, id)
	if err != nil {
		return fmt.Errorf("failed to delete post: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("failed to check rows affected: %w", err)
	}

	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *PostRepository) Count() (int, error) {
	var count int
	query := "SELECT COUNT(*) FROM posts"
	err := r.db.QueryRow(query).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts: %w", err)
	}
	return count, nil
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	query := "SELECT COUNT(*) FROM posts WHERE user_id = $1"
	err := r.db.QueryRow(query, userID).Scan(&count)
	if err != nil {
		return 0, fmt.Errorf("failed to count posts by user id: %w", err)
	}
	return count, nil
}
