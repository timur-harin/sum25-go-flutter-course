package repository

import (
	"context"
	"database/sql"
	"fmt"

	"lab04-backend/models"
)

// PostRepository handles database operations for posts
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

	query := `
		INSERT INTO posts (user_id, title, content, published, created_at, updated_at)
		VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
		RETURNING id, user_id, title, content, published, created_at, updated_at`

	post := new(models.Post)
	err := r.db.QueryRowContext(context.Background(), query,
		req.UserID, req.Title, req.Content, req.Published,
	).Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)

	if err != nil {
		return nil, err
	}
	return post, nil
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	query := "SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE id = ?"
	post := new(models.Post)
	err := r.db.QueryRowContext(context.Background(), query, id).Scan(
		&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return post, nil
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	query := "SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE user_id = ? ORDER BY created_at DESC"
	rows, err := r.db.QueryContext(context.Background(), query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		var post models.Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	query := "SELECT id, user_id, title, content, published, created_at, updated_at FROM posts WHERE published = true ORDER BY created_at DESC"
	rows, err := r.db.QueryContext(context.Background(), query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		var post models.Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	query := "SELECT id, user_id, title, content, published, created_at, updated_at FROM posts ORDER BY created_at DESC"
	rows, err := r.db.QueryContext(context.Background(), query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []models.Post
	for rows.Next() {
		var post models.Post
		err := rows.Scan(&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)
		if err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	return posts, nil
}

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

	post := new(models.Post)
	err := r.db.QueryRowContext(context.Background(), query, args...).Scan(
		&post.ID, &post.UserID, &post.Title, &post.Content, &post.Published, &post.CreatedAt, &post.UpdatedAt)

	if err != nil {
		return nil, err
	}
	return post, nil
}

func (r *PostRepository) Delete(id int) error {
	result, err := r.db.ExecContext(context.Background(), "DELETE FROM posts WHERE id = ?", id)
	if err != nil {
		return err
	}
	count, err := result.RowsAffected()
	if err != nil {
		return err
	}
	if count == 0 {
		return fmt.Errorf("post with id %d not found", id)
	}
	return nil
}

func (r *PostRepository) Count() (int, error) {
	var count int
	err := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts").Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (r *PostRepository) CountByUserID(userID int) (int, error) {
	var count int
	err := r.db.QueryRowContext(context.Background(), "SELECT COUNT(*) FROM posts WHERE user_id = ?", userID).Scan(&count)
	if err != nil {
		return 0, err
	}
	return count, nil
}
