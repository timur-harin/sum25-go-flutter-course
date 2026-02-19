package models

import (
	"fmt"
	"log"
	"regexp"
	"strings"

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

// BeforeCreate hook - GORM BeforeCreate hook
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// Validate data before creation
	if strings.TrimSpace(c.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}
	if len(strings.TrimSpace(c.Name)) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}
	if len(strings.TrimSpace(c.Name)) > 100 {
		return fmt.Errorf("name cannot exceed 100 characters")
	}
	if len(strings.TrimSpace(c.Description)) > 500 {
		return fmt.Errorf("description cannot exceed 500 characters")
	}
	// Set default color if not provided
	if c.Color == "" {
		c.Color = "#007bff"
	}
	// Validate hex color format
	if c.Color != "" {
		hexRegex := regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
		if !hexRegex.MatchString(c.Color) {
			return fmt.Errorf("invalid hex color format")
		}
	}
	return nil
}

// AfterCreate hook - GORM AfterCreate hook
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// Log creation
	log.Printf("Category created: %s (ID: %d)", c.Name, c.ID)
	return nil
}

// BeforeUpdate hook - GORM BeforeUpdate hook
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// Validate changes
	if strings.TrimSpace(c.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}
	if len(strings.TrimSpace(c.Name)) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}
	if len(strings.TrimSpace(c.Name)) > 100 {
		return fmt.Errorf("name cannot exceed 100 characters")
	}
	if len(strings.TrimSpace(c.Description)) > 500 {
		return fmt.Errorf("description cannot exceed 500 characters")
	}
	// Validate hex color format
	if c.Color != "" {
		hexRegex := regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
		if !hexRegex.MatchString(c.Color) {
			return fmt.Errorf("invalid hex color format")
		}
	}
	return nil
}

// Validate validates CreateCategoryRequest fields
func (req *CreateCategoryRequest) Validate() error {
	if strings.TrimSpace(req.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}
	if len(strings.TrimSpace(req.Name)) < 2 {
		return fmt.Errorf("name must be at least 2 characters long")
	}
	if len(strings.TrimSpace(req.Name)) > 100 {
		return fmt.Errorf("name cannot exceed 100 characters")
	}
	if len(strings.TrimSpace(req.Description)) > 500 {
		return fmt.Errorf("description cannot exceed 500 characters")
	}
	if req.Color != "" {
		hexRegex := regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
		if !hexRegex.MatchString(req.Color) {
			return fmt.Errorf("invalid hex color format")
		}
	}
	return nil
}

// ToCategory converts request to GORM model
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

// ActiveCategories - GORM scope for active categories
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts - GORM scope for categories with posts
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Preload("Posts")
}

// IsActive checks if category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount gets post count for this category using GORM association
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	count := db.Model(c).Association("Posts").Count()
	return int64(count), nil
}
