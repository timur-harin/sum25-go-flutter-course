package models

import (
	"fmt"
	"log"
	"time"

	"github.com/go-playground/validator/v10"
	"gorm.io/gorm"
)

type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"`
	Active      *bool          `json:"active" gorm:"not null;default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

type CreateCategoryRequest struct {
	Name        string `json:"name" validate:"required,min=2,max=100"`
	Description string `json:"description" validate:"max=500"`
	Color       string `json:"color" validate:"omitempty,hexcolor"`
}

type UpdateCategoryRequest struct {
	Name        *string `json:"name,omitempty" validate:"omitempty,min=2,max=100"`
	Description *string `json:"description,omitempty" validate:"omitempty,max=500"`
	Color       *string `json:"color,omitempty" validate:"omitempty,hexcolor"`
	Active      *bool   `json:"active,omitempty"`
}

func (Category) TableName() string {
	return "categories"
}

func (c *Category) BeforeCreate(tx *gorm.DB) error {
	if c.Color == "" {
		c.Color = "#CCCCCC"
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	log.Printf("Category '%s' (ID: %d) created successfully", c.Name, c.ID)
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	if tx.Statement.Changed("Name") {
		if newName, ok := tx.Statement.Dest.(map[string]interface{})["name"]; ok {
			if nameStr, isStr := newName.(string); isStr && nameStr == "" {
				return fmt.Errorf("category name cannot be updated to an empty string")
			}
		}
	}
	return nil
}

func (req *CreateCategoryRequest) Validate() error {
	validate := validator.New()
	return validate.Struct(req)
}

func (req *CreateCategoryRequest) ToCategory() *Category {
	return &Category{
		Name:        req.Name,
		Description: req.Description,
		Color:       req.Color,
	}
}

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories ON post_categories.category_id = categories.id").
		Group("categories.id")
}

func (c *Category) IsActive() bool {
	return c.Active != nil && *c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	count := db.Model(c).Association("Posts").Count()
	if db.Error != nil {
		return 0, db.Error
	}
	return count, nil
}
