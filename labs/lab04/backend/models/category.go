package models

import (
	"errors"
	"regexp"
	"strings"
	"time"

	"gorm.io/gorm"
)

type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color" gorm:"size:7"`
	Active      bool           `json:"active" gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at" gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at" gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
	Posts       []Post         `json:"posts,omitempty" gorm:"many2many:post_categories;"`
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
		c.Color = "#007bff"
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	// логирование можно добавить при необходимости
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// можно добавить защиту от деактивации системных категорий и т.п.
	return nil
}

func (req *CreateCategoryRequest) Validate() error {
	if len(strings.TrimSpace(req.Name)) < 2 {
		return errors.New("category name must be at least 2 characters")
	}
	if len(req.Color) > 0 && !regexp.MustCompile(`^#[0-9a-fA-F]{6}$`).MatchString(req.Color) {
		return errors.New("invalid color code")
	}
	if len(req.Description) > 500 {
		return errors.New("description too long")
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
	return db.Joins("JOIN post_categories ON post_categories.category_id = categories.id").Joins("JOIN posts ON posts.id = post_categories.post_id")
}

func (c *Category) IsActive() bool {
	return c.Active
}

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	count := db.Model(c).Association("Posts").Count()
	return count, nil
}
