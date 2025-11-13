package repository

import (
	"database/sql"
	"errors"

	"lab04-backend/models"
)

type DBTX interface {
	Query(query string, args ...any) (*sql.Rows, error)
	QueryRow(query string, args ...any) *sql.Row
	Exec(query string, args ...any) (sql.Result, error)
}

type PostRepository struct {
	db DBTX
}

func NewPostRepository(db DBTX) *PostRepository {
	return &PostRepository{db: db}
}

func (r *PostRepository) Create(post *models.Post) error {
	query := `
		INSERT INTO posts (title, content)
		VALUES ($1, $2)
		RETURNING id, title, content, created_at, updated_at
	`
	row := r.db.QueryRow(query, post.Title, post.Content)
	return post.ScanRow(row)
}

func (r *PostRepository) GetByID(id int64) (*models.Post, error) {
	query := `
		SELECT id, title, content, created_at, updated_at
		FROM posts
		WHERE id = $1
	`
	row := r.db.QueryRow(query, id)
	post := &models.Post{}
	if err := post.ScanRow(row); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}
	return post, nil
}

func (r *PostRepository) GetAll() ([]*models.Post, error) {
	query := `
		SELECT id, title, content, created_at, updated_at
		FROM posts
	`
	rows, err := r.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var posts []*models.Post
	for rows.Next() {
		post := &models.Post{}
		if err := post.ScanRows(rows); err != nil {
			return nil, err
		}
		posts = append(posts, post)
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	return posts, nil
}

func (r *PostRepository) Update(post *models.Post) error {
	query := `
		UPDATE posts
		SET title = $1, content = $2, updated_at = now()
		WHERE id = $3
		RETURNING id, title, content, created_at, updated_at
	`
	row := r.db.QueryRow(query, post.Title, post.Content, post.ID)
	return post.ScanRow(row)
}

func (r *PostRepository) Delete(id int64) error {
	query := `DELETE FROM posts WHERE id = $1`
	_, err := r.db.Exec(query, id)
	return err
}

func (r *PostRepository) Count() (int64, error) {
	query := `SELECT COUNT(*) FROM posts`
	var count int64
	err := r.db.QueryRow(query).Scan(&count)
	return count, err
}
