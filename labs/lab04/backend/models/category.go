package models

import (
	"log"
	"time"

	"gorm.io/gorm"
)

// Category represents a blog post category using GORM model conventions
// This model demonstrates GORM ORM patterns and relationships
type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"` // Hex color code
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"` // Soft delete support

	// GORM Associations (demonstrates ORM relationships)
	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// CreateCategoryRequest represents the payload for creating a category
type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

// UpdateCategoryRequest represents the payload for updating a category
type UpdateCategoryRequest struct {
	Name        *string `json:"name,omitempty" validate:"omitempty,min=2,max=100"`
	Description *string `json:"description,omitempty" validate:"omitempty,max=500"`
	Color       *string `json:"color,omitempty" validate:"omitempty,hexcolor"`
	Active      *bool   `json:"active,omitempty"`
}

// TableName specifies the table name for GORM (optional - GORM auto-infers)
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook - validates data and sets default values before creation
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// Set default color if not provided
	if c.Color == "" {
		c.Color = "#007bff"
	}

	// Ensure name is trimmed
	if c.Name != "" {
		c.Name = trimString(c.Name)
	}

	// Ensure description is trimmed
	if c.Description != "" {
		c.Description = trimString(c.Description)
	}

	return nil
}

// AfterCreate hook - logs creation and performs post-creation tasks
func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: %s (ID: %d)", c.Name, c.ID)
	return nil
}

// BeforeUpdate hook - validates changes and prevents certain updates
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// Prevent updating name to empty string
	if c.Name == "" {
		return gorm.ErrInvalidData
	}

	// Trim strings before update
	if c.Name != "" {
		c.Name = trimString(c.Name)
	}

	if c.Description != "" {
		c.Description = trimString(c.Description)
	}

	return nil
}

// Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	// Basic validation
	if req.Name == "" {
		return gorm.ErrInvalidData
	}

	if len(req.Name) < 2 || len(req.Name) > 100 {
		return gorm.ErrInvalidData
	}

	if len(req.Description) > 500 {
		return gorm.ErrInvalidData
	}

	// Validate hex color if provided
	if req.Color != "" && !isValidHexColor(req.Color) {
		return gorm.ErrInvalidData
	}

	return nil
}

// ToCategory method - converts request to GORM model
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

// GORM scopes (reusable query logic)
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

// Model validation methods
func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	var count int64
	err := db.Model(&Post{}).Joins("JOIN post_categories ON post_categories.post_id = posts.id").Where("post_categories.category_id = ?", c.ID).Count(&count).Error
	return count, err
}

// Helper functions
func trimString(s string) string {
	// Simple trim implementation
	start := 0
	end := len(s)

	// Trim leading spaces
	for start < end && s[start] == ' ' {
		start++
	}

	// Trim trailing spaces
	for end > start && s[end-1] == ' ' {
		end--
	}

	return s[start:end]
}

func isValidHexColor(color string) bool {
	if len(color) != 7 || color[0] != '#' {
		return false
	}

	for i := 1; i < 7; i++ {
		c := color[i]
		if !((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
			return false
		}
	}

	return true
}
