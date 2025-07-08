-- +goose Up
-- +goose StatementBegin
-- Create posts table with foreign key relationship to users
CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create index for user posts lookup
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Create index for published posts
CREATE INDEX idx_posts_published ON posts(published);

-- Create index for soft delete queries
CREATE INDEX idx_posts_deleted_at ON posts(deleted_at);

-- Create composite index for common queries
CREATE INDEX idx_posts_user_published ON posts(user_id, published);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the posts table and its indexes
DROP INDEX IF EXISTS idx_posts_user_published;
DROP INDEX IF EXISTS idx_posts_deleted_at;
DROP INDEX IF EXISTS idx_posts_published;
DROP INDEX IF EXISTS idx_posts_user_id;
DROP TABLE posts;
-- +goose StatementEnd
