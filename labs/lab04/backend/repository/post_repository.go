package repository

import (
	"context"
	"database/sql"
	"fmt"

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

func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}
	var post models.Post
	query := `
		INSERT INTO posts (user_id, title, content, published)
		VALUES ($1, $2, $3, $4)
		RETURNING *`
	err := sqlscan.Get(context.Background(), r.db, &post, query,
		req.UserID, req.Title, req.Content, req.Published)
	return &post, err
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post,
		"SELECT * FROM posts WHERE id = $1", id)
	return &post, err
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	query := `SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC`
	err := sqlscan.Select(context.Background(), r.db, &posts, query, userID)
	return posts, err
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	query := `SELECT * FROM posts WHERE published = true ORDER BY created_at DESC`
	err := sqlscan.Select(context.Background(), r.db, &posts, query)
	return posts, err
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts ORDER BY created_at DESC")
	return posts, err
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

	setClauses = append(setClauses, fmt.Sprintf("updated_at = NOW()"))

	query := fmt.Sprintf(`
		UPDATE posts
		SET %s
		WHERE id = $%d
		RETURNING *`,
		joinClauses(setClauses, ", "), argPos)
	args = append(args, id)

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	return &post, err
}

func joinClauses(clauses []string, sep string) string {
	result := ""
	for i, clause := range clauses {
		if i > 0 {
			result += sep
		}
		result += clause
	}
	return result
}

func (r *PostRepository) Delete(id int) error {
	_, err := r.db.Exec("DELETE FROM posts WHERE id = $1", id)
	return err
}

func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts").Scan(&count)
	return count, err
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts WHERE user_id = $1", userID).Scan(&count)
	return count, err
}
