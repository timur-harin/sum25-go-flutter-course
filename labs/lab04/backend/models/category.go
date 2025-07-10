package models

import (
	"errors"
	"log"
	"strings"
	"time"

	"gorm.io/gorm"
)

// Category represents a blog post category using GORM model conventions
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"` // Hex color code
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"` // Soft delete support
	Posts       []Post         `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// CreateCategoryRequest represents the payload for creating a category
type CreateCategoryRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Color       string `json:"color"`
}

// UpdateCategoryRequest represents the payload for updating a category
type UpdateCategoryRequest struct {
	Name        *string `json:"name,omitempty"`
	Description *string `json:"description,omitempty"`
	Color       *string `json:"color,omitempty"`
	Active      *bool   `json:"active,omitempty"`
}

// TableName specifies the table name for GORM
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook — set default values and validate
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Name == "" {
		return errors.New("category name cannot be empty")
	}
	c.Name = strings.TrimSpace(c.Name)
	if c.Color == "" {
		c.Color = "#007bff"
	}
	return nil
}

// AfterCreate hook — logging
func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: ID=%d Name=%s", c.ID, c.Name)
	return nil
}

// BeforeUpdate hook — trim and basic validation
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	c.Name = strings.TrimSpace(c.Name)
	if len(c.Name) < 2 {
		return errors.New("category name too short")
	}
	return nil
}

// CreateCategoryRequest -> validation logic
func (req *CreateCategoryRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("name must be at least 2 characters")
	}
	if len(req.Color) > 0 && !strings.HasPrefix(req.Color, "#") {
		return errors.New("color must be a valid hex code")
	}
	if len(req.Description) > 500 {
		return errors.New("description too long")
	}
	return nil
}

// CreateCategoryRequest -> Category
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        strings.TrimSpace(req.Name),
		Description: strings.TrimSpace(req.Description),
		Color:       strings.TrimSpace(req.Color),
		Active:      true,
	}
}

// GORM Scopes

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

// Utility methods

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	var count int64
	err := db.Model(&Post{}).
		Joins("JOIN post_categories pc ON pc.post_id = posts.id").
		Where("pc.category_id = ?", c.ID).
		Count(&count).Error
	return count, err
}
