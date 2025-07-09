package models

import (
	"fmt"
	"log"
	"time"

	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
)

const (
	DefaultColor     = "#007bff"
	MinNameLength    = 2
	MaxNameLength    = 100
	MaxDescLength    = 500
	DefaultHexLength = 7
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

// TODO: Implement BeforeCreate hook
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// TODO: GORM BeforeCreate hook
	// - Validate data before creation
	// - Set default values
	// - Perform any pre-creation logic
	// Example: if c.Color == "" { c.Color = "#007bff" }

	if c.Color == "" {
		c.Color = DefaultColor
	}

	if len(c.Name) < MinNameLength || len(c.Name) > MaxNameLength {
		return fmt.Errorf("name length must be between %d and %d characters", MinNameLength, MaxNameLength)
	}

	if len(c.Description) > MaxDescLength {
		return fmt.Errorf("description length must not exceed %d characters", MaxDescLength)
	}

	return nil
}

// TODO: Implement AfterCreate hook
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// TODO: GORM AfterCreate hook
	// - Log creation
	// - Send notifications
	// - Update cache
	log.Printf("Category created: %s", c.Name)

	return nil
}

// TODO: Implement BeforeUpdate hook
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// TODO: GORM BeforeUpdate hook
	// - Validate changes
	// - Prevent certain updates
	// - Clean up related data

	if c.Name != "" && (len(c.Name) < MinNameLength || len(c.Name) > MaxNameLength) {
		return fmt.Errorf("name length must be between %d and %d characters", MinNameLength, MaxNameLength)
	}

	if len(c.Description) > MaxDescLength {
		return fmt.Errorf("description length must not exceed %d characters", MaxDescLength)
	}

	return nil
}

// TODO: Implement Validate method for CreateCategoryRequest
func (req *CreateCategoryRequest) Validate() error {
	// TODO: Add validation logic for GORM model
	// - Name should be unique (checked at database level via GORM)
	// - Color should be valid hex color
	// - Description should not exceed limits
	// Example using validator package:

	validate := validator.New()
	return validate.Struct(req)
}

// TODO: Implement ToCategory method
func (req *CreateCategoryRequest) ToCategory() *Category {
	// TODO: Convert request to GORM model
	// - Map fields from request to model
	// - Set default values
	// Example:
	// return &Category{
	//     Name:        req.Name,
	//     Description: req.Description,
	//     Color:       req.Color,
	//     Active:      true,
	// }

	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}

	return nil
}

// TODO: Implement GORM scopes (reusable query logic)
func ActiveCategories(db *gorm.DB) *gorm.DB {
	// TODO: GORM scope for active categories
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	// TODO: GORM scope for categories with posts
	return db.Joins("Posts").Where("posts.id IS NOT NULL")
}

// TODO: Implement model validation methods
func (c *Category) IsActive() bool {
	// TODO: Check if category is active
	return c.Active
}

// func (c *Category) PostCount(db *gorm.DB) (int64, error) {
// 	// TODO: Get post count for this category using GORM association
// 	var count int64
// 	err := db.Model(c).Association("Posts").Count(&count)
// return count, err
//
// }
