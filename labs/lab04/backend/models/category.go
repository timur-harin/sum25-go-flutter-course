package models

import (
	"errors"
	"log"
	"regexp"
	"time"

	"gorm.io/gorm"
)

var (
	ErrEmptyCategoryName    = errors.New("empty category name")
	ErrShortCategoryName    = errors.New("category name too short")
	ErrLongCategoryName     = errors.New("category name too long")
	ErrLongCategoryDesc     = errors.New("category description too long")
	ErrInvalidCategoryColor = errors.New("invalid category color")

	hexColorRegex = regexp.MustCompile(`^#[0-9A-Fa-f]{6}$`)
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

	// Validate the category before creation
	if err := c.Validate(); err != nil {
		return err
	}

	return nil
}

// AfterCreate hook - logs creation and can be used for notifications
func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: %s (ID: %d)", c.Name, c.ID)
	return nil
}

// BeforeUpdate hook - validates changes before updating
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// Validate the category before update
	if err := c.Validate(); err != nil {
		return err
	}

	return nil
}

// Validate method for Category model
func (c *Category) Validate() error {
	if c.Name == "" {
		return ErrEmptyCategoryName
	}
	if len(c.Name) < 2 {
		return ErrShortCategoryName
	}
	if len(c.Name) > 100 {
		return ErrLongCategoryName
	}
	if len(c.Description) > 500 {
		return ErrLongCategoryDesc
	}
	if c.Color != "" && !hexColorRegex.MatchString(c.Color) {
		return ErrInvalidCategoryColor
	}
	return nil
}

// Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	if req.Name == "" {
		return ErrEmptyCategoryName
	}
	if len(req.Name) < 2 {
		return ErrShortCategoryName
	}
	if len(req.Name) > 100 {
		return ErrLongCategoryName
	}
	if len(req.Description) > 500 {
		return ErrLongCategoryDesc
	}
	if req.Color != "" && !hexColorRegex.MatchString(req.Color) {
		return ErrInvalidCategoryColor
	}
	return nil
}

// ToCategory converts CreateCategoryRequest to Category model
func (req *CreateCategoryRequest) ToCategory() *Category {
	now := time.Now()
	color := req.Color
	if color == "" {
		color = "#007bff"
	}

	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       color,
		Active:      true,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
}

// GORM scopes for reusable query logic

// ActiveCategories scope filters for active categories only
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts scope gets categories that have associated posts
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

// Model validation methods

// IsActive checks if category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount gets the number of posts associated with this category
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	count := db.Model(c).Association("Posts").Count()
	return count, nil
}
