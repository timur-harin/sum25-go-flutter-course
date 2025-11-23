package repository

import (
	"context"
	"database/sql"

	"lab04-backend/models"
)

// PostRepository handles database operations for posts
// This repository demonstrates manual SQL mapping approach for result scanning
type PostRepository struct {
	db *sql.DB
}

// NewPostRepository creates a new PostRepository
func NewPostRepository(db *sql.DB) *PostRepository {
	return &PostRepository{db: db}
}

// TODO: Implement Create method using manual scanning for result mapping
func (r *PostRepository) Create(req *models.CreatePostRequest) (*models.Post, error) {
	if err := req.Validate(); err != nil {
		return nil, err
	}

	query := `INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
                VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                RETURNING id, user_id, title, content, published, created_at, updated_at`

	row := r.db.QueryRowContext(context.Background(), query,
		req.UserID, req.Title, req.Content, req.Published)
	var post models.Post
	if err := row.Scan(&post.ID, &post.UserID, &post.Title, &post.Content,
		&post.Published, &post.CreatedAt, &post.UpdatedAt); err != nil {
		return nil, err
	}
	return &post, nil
}

// TODO: Implement GetByID method using manual scanning
func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	row := r.db.QueryRowContext(context.Background(),
		"SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE id = ?", id)
	var post models.Post
	if err := row.Scan(&post.ID, &post.UserID, &post.Title, &post.Content,
		&post.Published, &post.CreatedAt, &post.UpdatedAt); err != nil {
		return nil, err
	}
	return &post, nil
}

// TODO: Implement GetByUserID method using manual scanning
func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	rows, err := r.db.QueryContext(context.Background(),
		"SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE user_id = ? ORDER BY created_at DESC",
		userID)
	if err != nil {
		return nil, err
	}
	return models.ScanPosts(rows)
}

// TODO: Implement GetPublished method using manual scanning
func (r *PostRepository) GetPublished() ([]models.Post, error) {
	rows, err := r.db.QueryContext(context.Background(),
		"SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE published = 1 ORDER BY created_at DESC")
	if err != nil {
		return nil, err
	}
	return models.ScanPosts(rows)
}

// TODO: Implement GetAll method using manual scanning
func (r *PostRepository) GetAll() ([]models.Post, error) {
	rows, err := r.db.QueryContext(context.Background(),
		"SELECT id, user_id, title, content, published, created_at, updated_at FROM posts ORDER BY created_at DESC")
	if err != nil {
		return nil, err
	}
	return models.ScanPosts(rows)
}

// TODO: Implement Update method using manual scanning
func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
	query := "UPDATE posts SET "
	args := []interface{}{}
	if req.Title != nil {
		query += "title = ?, "
		args = append(args, *req.Title)
	}
	if req.Content != nil {
		query += "content = ?, "
		args = append(args, *req.Content)
	}
	if req.Published != nil {
		query += "published = ?, "
		args = append(args, *req.Published)
	}
	query += "updated_at = CURRENT_TIMESTAMP WHERE id = ? RETURNING id, user_id, title, content, published, created_at, updated_at"
	args = append(args, id)
	var post models.Post
	row := r.db.QueryRowContext(context.Background(), query, args...)
	if err := row.Scan(&post.ID, &post.UserID, &post.Title, &post.Content,
		&post.Published, &post.CreatedAt, &post.UpdatedAt); err != nil {
		return nil, err
	}
	return &post, nil
}

// TODO: Implement Delete method (standard SQL)
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

// TODO: Implement Count method (standard SQL)
func (r *PostRepository) Count() (int, error) {
	row := r.db.QueryRow("SELECT COUNT(*) FROM posts")
	var count int
	if err := row.Scan(&count); err != nil {
		return 0, err
	}
	return count, nil
}

// TODO: Implement CountByUserID method (standard SQL)
func (r *PostRepository) CountByUserID(userID int) (int, error) {
	row := r.db.QueryRow("SELECT COUNT(*) FROM posts WHERE user_id = ?", userID)
	var count int
	if err := row.Scan(&count); err != nil {
		return 0, err
	}
	return count, nil
}
