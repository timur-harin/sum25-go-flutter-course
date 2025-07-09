package models

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/go-playground/validator/v10"
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
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

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

// TableName overrides GORM table naming (optional)
func (Category) TableName() string {
	return "categories"
}

// BeforeCreate hook - run before saving a new category
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if strings.TrimSpace(c.Color) == "" {
		c.Color = "#007bff"
	}
	return nil
}

// AfterCreate hook - run after creating a category
func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category created: ID=%d, Name=%s", c.ID, c.Name)
	return nil
}

// BeforeUpdate hook - run before updating a category
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// Example: ensure name isn't empty
	if strings.TrimSpace(c.Name) == "" {
		return fmt.Errorf("category name cannot be empty")
	}
	return nil
}

// Validate validates the CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	validate := validator.New()
	return validate.Struct(req)
}

// ToCategory converts CreateCategoryRequest to a Category model
func (req *CreateCategoryRequest) ToCategory() *Category {
	color := req.Color
	if strings.TrimSpace(color) == "" {
		color = "#007bff"
	}

	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       color,
		Active:      true,
	}
}

// ActiveCategories GORM scope
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts GORM scope
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.
		Joins("JOIN post_categories ON categories.id = post_categories.category_id").
		Joins("JOIN posts ON post_categories.post_id = posts.id").
		Group("categories.id")
}

// IsActive returns true if the category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount returns the number of posts in a category
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	count := db.Model(c).Association("Posts").Count()
	return count, nil
}
