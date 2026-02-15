package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/georgysavva/scany/v2/sqlscan"

	"lab04-backend/models"
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

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	query := `INSERT INTO posts (user_id, title, content, published, created_at, updated_at) VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP) RETURNING id, user_id, title, content, published, created_at, updated_at`
	var post models.Post
	if err := sqlscan.Get(context.Background(), r.db, &post, query, req.UserID, req.Title, req.Content, req.Published); err != nil {
		return nil, err
	}
	return &post, nil
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE id = ?`
	var post models.Post
	if err := sqlscan.Get(context.Background(), r.db, &post, query, id); err != nil {
		return nil, err
	}
	return &post, nil
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE user_id = ? ORDER BY created_at DESC`
	var posts []models.Post
	if err := sqlscan.Select(context.Background(), r.db, &posts, query, userID); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE published = 1 ORDER BY created_at DESC`
	var posts []models.Post
	if err := sqlscan.Select(context.Background(), r.db, &posts, query); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts ORDER BY created_at DESC`
	var posts []models.Post
	if err := sqlscan.Select(context.Background(), r.db, &posts, query); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	fields := []string{}
	args := []interface{}{}
	if req.Title != nil {
		fields = append(fields, "title = ?")
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		fields = append(fields, "content = ?")
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		fields = append(fields, "published = ?")
		args = append(args, *req.Published)
	}
	if len(fields) == 0 {
		return nil, fmt.Errorf("no fields to update")
	}
	updatedAt := time.Now()
	fields = append(fields, "updated_at = ?")
	args = append(args, updatedAt)
	query := fmt.Sprintf("UPDATE posts SET %s WHERE id = ? RETURNING id, user_id, title, content, published, created_at, updated_at",
		strings.Join(fields, ", "))
	args = append(args, id)
	var post models.Post
	if err := sqlscan.Get(context.Background(), r.db, &post, query, args...); err != nil {
		return nil, err
	}
	return &post, nil
}

func (r *PostRepository) Delete(id int) error {
	res, err := r.db.Exec("DELETE FROM posts WHERE id = ?", id)
	if err != nil {
		return err
	}
	affected, err := res.RowsAffected()
	if err != nil {
		return err
	}
	if affected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts").Scan(&count)
	return count, err
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts WHERE user_id = ?", userID).Scan(&count)
	return count, err
}
