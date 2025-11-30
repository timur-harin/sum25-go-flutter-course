package repository

import (
	"context"
	"database/sql"
	"fmt"
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

	post := req.ToPost()
	query := `INSERT INTO posts (user_id, title, content, published, created_at, updated_at) 
	          VALUES ($1, $2, $3, $4, $5, $6) 
	          RETURNING id, user_id, title, content, published, created_at, updated_at`

	err := sqlscan.Get(context.Background(), r.db, post, query,
		post.UserID, post.Title, post.Content, post.Published, post.CreatedAt, post.UpdatedAt)
	
	return post, err
}

func (r *PostRepository) GetByID(id int) (*models.Post, error) {
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, 
		"SELECT * FROM posts WHERE id = $1", id)
	return &post, err
}

func (r *PostRepository) GetByUserID(userID int) ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts WHERE user_id = $1 ORDER BY created_at DESC", userID)
	return posts, err
}

func (r *PostRepository) GetPublished() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts WHERE published = true ORDER BY created_at DESC")
	return posts, err
}

func (r *PostRepository) GetAll() ([]models.Post, error) {
	var posts []models.Post
	err := sqlscan.Select(context.Background(), r.db, &posts,
		"SELECT * FROM posts ORDER BY created_at DESC")
	return posts, err
}

func (r *PostRepository) Update(id int, req *models.UpdatePostRequest) (*models.Post, error) {
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

	query += "updated_at = NOW() WHERE id = $%d RETURNING *"
	args = append(args, id)

	fullQuery := fmt.Sprintf(query, argPos)
	
	var post models.Post
	err := sqlscan.Get(context.Background(), r.db, &post, fullQuery, args...)
	return &post, err
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