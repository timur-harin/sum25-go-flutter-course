package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"lab04-backend/models"

	"github.com/georgysavva/scany/sqlscan"
)

type PostRepository struct {
	db *sql.DB
}

func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	now := time.Now()

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query,
		req.UserID, req.Title, req.Content, req.Published, now, now)
	if err != nil {
		return nil, fmt.Errorf("failed to create post: %w", err)
	}

	return &post, nil
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE id = $1`
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post not found")
		}
		return nil, err
	}
	return &post, nil
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE user_id = $1 ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE published = true ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts ORDER BY created_at DESC`
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	setClauses := []string{}
	args := []interface{}{}
	argPos := 1

	if req.Title != nil {
		setClauses = append(setClauses, fmt.Sprintf("title = $%d", argPos))
		args = append(args, *req.Title)
		argPos++
	}
	if req.Content != nil {
		setClauses = append(setClauses, fmt.Sprintf("content = $%d", argPos))
		args = append(args, *req.Content)
		argPos++
	}
	if req.Published != nil {
		setClauses = append(setClauses, fmt.Sprintf("published = $%d", argPos))
		args = append(args, *req.Published)
		argPos++
	}
	if len(setClauses) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}

	setClauses = append(setClauses, fmt.Sprintf("updated_at = $%d", argPos))
	args = append(args, time.Now())
	argPos++

	args = append(args, id)

	query := fmt.Sprintf(
		`UPDATE posts SET %s WHERE id = $%d RETURNING id, user_id, title, content, published, created_at, updated_at`,
		strings.Join(setClauses, ", "), argPos)

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("post not found")
		}
		return nil, err
	}
	return &post, nil
}

func (r *PostRepository) Delete(id int) error {
	res, err := r.db.Exec(`DELETE FROM posts WHERE id = $1`, id)
	if err != nil {
		return err
	}
	rowsAffected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return fmt.Errorf("post not found")
	}
	return nil
}

func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM posts`).Scan(&count)
	return count, err
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM posts WHERE user_id = $1`, userID).Scan(&count)
	return count, err
}
