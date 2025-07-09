package models

import (
	"fmt"
	"regexp"
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

// TODO: Implement GORM model methods and hooks

// TableName specifies the table name for GORM (optional - GORM auto-infers)
func (Category) TableName() string {
	return "categories"
}

func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Color == "" {
		c.Color = "#007bff"
	}
	if len(c.Name) < 2 {
		return fmt.Errorf("category name must be at least 2 characters")
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	fmt.Printf("Category created: %s\n", c.Name)
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if c.Name != "" && len(c.Name) < 2 {
		return fmt.Errorf("category name must be at least 2 characters")
	}
	return nil
}

func (req *CreateCategoryRequest) Validate() error {
	if len(req.Name) < 2 {
		return fmt.Errorf("category name must be at least 2 characters")
	}
	if req.Color != "" && !isHexColor(req.Color) {
		return fmt.Errorf("invalid color format")
	}
	if len(req.Description) > 500 {
		return fmt.Errorf("description too long")
	}
	return nil
}

func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) int64 {
	return db.Model(c).Association("Posts").Count()
}

func isHexColor(s string) bool {
	matched, _ := regexp.MatchString(`^#[0-9a-fA-F]{6}$`, s)
	return matched
}
