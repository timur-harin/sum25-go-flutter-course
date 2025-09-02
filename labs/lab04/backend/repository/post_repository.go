package repository

import (
	"context"
	"database/sql"
	"fmt"

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

// TODO: Implement Create method using scany for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if req == nil {
		return nil, fmt.Errorf("invalid request")
	}
	if err := req.Validate(); err != nil {
		return nil, err
	}
	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, req.UserID, req.Title, req.Content, req.Published)
	if err != nil {
		return nil, err
	}
	return &post, nil
}

// TODO: Implement GetByID method using scany
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE id = $1`, id)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, err
	}
	return &post, nil
}

// TODO: Implement GetByUserID method using scany
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE user_id = $1 ORDER BY created_at DESC`, userID)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// TODO: Implement GetPublished method using scany
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE published = true ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// TODO: Implement GetAll method using scany
func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts, `SELECT id, user_id, title, content, published, created_at, updated_at FROM posts ORDER BY created_at DESC`)
	if err != nil {
		return nil, err
	}
	return posts, nil
}

// TODO: Implement Update method using scany
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	if req == nil {
		return nil, fmt.Errorf("invalid request")
	}
	setClauses := []string{}
	args := []interface{}{}
	argIdx := 1

	if req.Title != nil {
		setClauses = append(setClauses, fmt.Sprintf("title = $%d", argIdx))
		args = append(args, *req.Title)
		argIdx++
	}
	if req.Content != nil {
		setClauses = append(setClauses, fmt.Sprintf("content = $%d", argIdx))
		args = append(args, *req.Content)
		argIdx++
	}
	if req.Published != nil {
		setClauses = append(setClauses, fmt.Sprintf("published = $%d", argIdx))
		args = append(args, *req.Published)
		argIdx++
	}
	if len(setClauses) == 0 {
		return r.GetByID(id)
	}
	setClauses = append(setClauses, "updated_at = CURRENT_TIMESTAMP")

	query := fmt.Sprintf(`
		UPDATE posts SET %s WHERE id = $%d
		RETURNING id, user_id, title, content, published, created_at, updated_at
	`, joinClauses(setClauses, ", "), argIdx)
	args = append(args, id)

	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, query, args...)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, sql.ErrNoRows
		}
		return nil, err
	}
	return &post, nil
}

// TODO: Implement Delete method (standard SQL)
func (r *PostRepository) Delete(id int) error {
	result, err := r.db.Exec("DELETE FROM posts WHERE id = $1", id)
	if err != nil {
		return err
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}
	return nil
}

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts").Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRow("SELECT COUNT(*) FROM posts WHERE user_id = $1", userID).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}

// joinClauses is a helper for joining SQL SET clauses (for Update)
func joinClauses(clauses []string, sep string) string {
	if len(clauses) == 0 {
		return ""
	}
	result := clauses[0]
	for i := 1; i < len(clauses); i++ {
		result += sep + clauses[i]
	}
	return result
}
