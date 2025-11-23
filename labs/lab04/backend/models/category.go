package models

import (
	"errors"
	"log"
	"regexp"
	"time"

	"gorm.io/gorm"
)

var hexColorRegexp = regexp.MustCompile(`^#[0-9a-fA-F]{6}$`)

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

// TODO: Implement GORM model methods and hooks

// TableName specifies the table name for GORM (optional - GORM auto-infers)
func (Category) TableName() string {
	return "categories"
}

// TODO: Implement BeforeCreate hook
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// Validate required fields
	if c.Name == "" || len(c.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}

	// Set default color if not provided
	if c.Color == "" {
		c.Color = "#007bff"
	}

	// Validate hex color format if provided
	if c.Color != "" && !hexColorRegexp.MatchString(c.Color) {
		return errors.New("invalid color format")
	}

	return nil
}

// TODO: Implement AfterCreate hook
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// Simple log after creation
	log.Printf("Category created: %s", c.Name)
	return nil
}

// TODO: Implement BeforeUpdate hook
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// Validate required fields before updating
	if c.Name == "" || len(c.Name) < 2 {
		return errors.New("name must be at least 2 characters")
	}

	if c.Color != "" && !hexColorRegexp.MatchString(c.Color) {
		return errors.New("invalid color format")
	}

	return nil
}

// TODO: Implement Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	if len(req.Name) < 2 || len(req.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if len(req.Description) > 500 {
		return errors.New("description must be at most 500 characters")
	}
	if req.Color != "" && !hexColorRegexp.MatchString(req.Color) {
		return errors.New("invalid color format")
	}
	return nil
}

// TODO: Implement ToCategory method
func (req *CreateCategoryRequest) ToCategory() *Category {
	color := req.Color
	if color == "" {
		color = "#007bff"
	}
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       color,
		Active:      true,
	}
}

// TODO: Implement GORM scopes (reusable query logic)
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

// TODO: Implement model validation methods
func (c *Category) IsActive() bool {
	return c.Active && !c.DeletedAt.Valid
}

func (c *Category) PostCount(db *gorm.DB) int64 {
	return db.Model(c).Association("Posts").Count()
}

func (c *Category) Validate() error {
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if c.Color != "" && !hexColorRegex.MatchString(c.Color) {
		return errors.New("invalid color format")
	}
	return nil
}

var hexColorRegex = regexp.MustCompile(`^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$`)
