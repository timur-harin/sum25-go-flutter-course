package repository

import "database/sql"

// PostRepository is a thin placeholder to satisfy main.go compile‑time dependencies.
type PostRepository struct {
    db *sql.DB
}

// NewPostRepository returns an empty PostRepository instance.
func NewPostRepository(db *sql.DB) *PostRepository {
    return &PostRepository{db: db}
}