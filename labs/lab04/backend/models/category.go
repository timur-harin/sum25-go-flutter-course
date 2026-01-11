package models

import (
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/go-playground/validator/v10"
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

	// GORM Associations
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

// BeforeCreate is a GORM hook that runs before creating a new Category
func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// Validate Name length
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return fmt.Errorf("name must be between 2 and 100 characters")
	}
	// Default color
	if c.Color == "" {
		c.Color = "#007bff"
	}
	// Ensure uniqueness of Name
	var count int64
	err := tx.Model(&Category{}).
		Where("name = ?", c.Name).
		Count(&count).Error
	if err != nil {
		return err
	}
	if count > 0 {
		return fmt.Errorf("category with name %q already exists", c.Name)
	}
	return nil
}

// AfterCreate is a GORM hook that runs after a Category has been created
func (c *Category) AfterCreate(tx *gorm.DB) error {
	// Log creation
	log.Printf("[Category Created] ID=%d, Name=%q", c.ID, c.Name)

	// Send notifications asynchronously
	go func(cat *Category) {
		log.Printf("[Notification sent] ID=%d, Name=%q", c.ID, c.Name)

		// err := notifyService.NotifyCategoryCreated(cat)
		// if err != nil {
		//	log.Printf("failed to send creation notification for category %d: %v", cat.ID, err)
		// }
	}(c)

	// Update cache
	key := "category:" + strconv.FormatUint(uint64(c.ID), 10)
	log.Printf("[Cache apdated] ID=%d, Name=%q, %s", c.ID, c.Name, key)
	/* err := cacheClient.Set(key, c, 0).Err()
	if err != nil {
		log.Printf("failed to set cache for category %d: %v", c.ID, err)
	} */
	return nil
}

// BeforeUpdate is a GORM hook that runs before updating an existing Category
func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// If name is being changed, validate its length and uniqueness
	if tx.Statement.Changed("Name") {
		if len(c.Name) < 2 || len(c.Name) > 100 {
			return fmt.Errorf("name must be between 2 and 100 characters")
		}
		var count int64
		err := tx.Model(&Category{}).
			Where("name = ? AND id <> ?", c.Name, c.ID).
			Count(&count).Error
		if err != nil {
			return err
		}
		if count > 0 {
			return fmt.Errorf("category with name %q already exists", c.Name)
		}
	}
	// Ensure default color if empty
	if tx.Statement.Changed("Color") && c.Color == "" {
		c.Color = "#007bff"
	}
	return nil
}

// Validate checks CreateCategoryRequest fields using validator tags
func (req *CreateCategoryRequest) Validate() error {
	validate := validator.New()
	return validate.Struct(req)
}

// ToCategory converts CreateCategoryRequest to Category model
func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
		Active:      true,
	}
}

// ActiveCategories is a GORM scope for filtering active categories
func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

// CategoriesWithPosts is a GORM scope for categories having at least one post
func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories pc ON pc.category_id = categories.id").
		Joins("JOIN posts p ON p.id = pc.post_id").
		Where("p.id IS NOT NULL")
}

// IsActive returns true if the category is active
func (c *Category) IsActive() bool {
	return c.Active
}

// PostCount returns the number of posts associated with this category
func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	var count int64
	err := db.
		Model(&Post{}).
		// здесь предполагаем, что связь через pivot post_categories
		Joins("JOIN post_categories pc ON pc.post_id = posts.id").
		Where("pc.category_id = ?", c.ID).
		Count(&count).
		Error
	if err != nil {
		return 0, err
	}
	return count, nil
}
