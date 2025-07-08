-- +goose Up
-- +goose StatementBegin
-- Create categories table for GORM example
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    color VARCHAR(7), -- Hex color code
    active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL -- For GORM soft delete
);

-- Create many-to-many junction table for posts and categories
CREATE TABLE post_categories (
    post_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, category_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Create indexes for efficient lookups
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_categories_active ON categories(active);
CREATE INDEX idx_categories_deleted_at ON categories(deleted_at);
CREATE INDEX idx_post_categories_post_id ON post_categories(post_id);
CREATE INDEX idx_post_categories_category_id ON post_categories(category_id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- Drop the categories tables and indexes
DROP INDEX IF EXISTS idx_post_categories_category_id;
DROP INDEX IF EXISTS idx_post_categories_post_id;
DROP INDEX IF EXISTS idx_categories_deleted_at;
DROP INDEX IF EXISTS idx_categories_active;
DROP INDEX IF EXISTS idx_categories_name;
DROP TABLE post_categories;
DROP TABLE categories;
-- +goose StatementEnd
