package models

import (
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"gorm.io/gorm"
)

// -----------------------------------------------------------------------------
// Модель категории
// -----------------------------------------------------------------------------

type Category struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name"        gorm:"size:100;not null;uniqueIndex"`
	Description string         `json:"description" gorm:"size:500"`
	Color       string         `json:"color"       gorm:"size:7"` // #RRGGBB
	Active      bool           `json:"active"      gorm:"default:true"`
	CreatedAt   time.Time      `json:"created_at"  gorm:"autoCreateTime"`
	UpdatedAt   time.Time      `json:"updated_at"  gorm:"autoUpdateTime"`
	DeletedAt   gorm.DeletedAt `json:"-"           gorm:"index"`

	// GORM many-to-many через таблицу post_categories
	Posts []Post `json:"posts,omitempty" gorm:"many2many:post_categories;"`
}

// -----------------------------------------------------------------------------
// Запросы / DTO
// -----------------------------------------------------------------------------

type CreateCategoryRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Color       string `json:"color"` // #RRGGBB или пусто
}

type UpdateCategoryRequest struct {
	Name        *string `json:"name,omitempty"`
	Description *string `json:"description,omitempty"`
	Color       *string `json:"color,omitempty"`
	Active      *bool   `json:"active,omitempty"`
}

// -----------------------------------------------------------------------------
// TableName — можно не переопределять, но оставим для явности
// -----------------------------------------------------------------------------

func (Category) TableName() string { return "categories" }

// -----------------------------------------------------------------------------
// GORM hooks
// -----------------------------------------------------------------------------

func (c *Category) BeforeCreate(tx *gorm.DB) error {
	// trim + базовая валидация
	c.Name = strings.TrimSpace(c.Name)
	if len(c.Name) < 2 || len(c.Name) > 100 {
		return errors.New("category name must be between 2 and 100 characters")
	}

	if c.Color == "" {
		c.Color = "#007bff" // дефолтный цвет
	}

	if !isHexColor(c.Color) {
		return fmt.Errorf("invalid color: %s", c.Color)
	}

	// Active по-умолчанию true
	if !c.Active {
		c.Active = true
	}
	return nil
}

func (c *Category) AfterCreate(tx *gorm.DB) error {
	// Пример простого логирования; можно заменить на свой logger
	fmt.Printf("[Category] created: id=%d name=%q\n", c.ID, c.Name)
	return nil
}

func (c *Category) BeforeUpdate(tx *gorm.DB) error {
	// При обновлении тоже проверяем валидность цвета
	if c.Color != "" && !isHexColor(c.Color) {
		return fmt.Errorf("invalid color: %s", c.Color)
	}
	return nil
}

// -----------------------------------------------------------------------------
// Validate + преобразование запроса
// -----------------------------------------------------------------------------

func (req *CreateCategoryRequest) Validate() error {
	req.Name = strings.TrimSpace(req.Name)
	if len(req.Name) < 2 || len(req.Name) > 100 {
		return errors.New("name must be between 2 and 100 characters")
	}
	if len(req.Description) > 500 {
		return errors.New("description exceeds 500 characters")
	}
	if req.Color != "" && !isHexColor(req.Color) {
		return errors.New("color must be hex in form #RRGGBB")
	}
	return nil
}

func (req *CreateCategoryRequest) ToCategory() *Category {
	// Если цвет не передали — оставим пустым, hook установит дефолт.
	return &Category{
		Name:        strings.TrimSpace(req.Name),
		Description: strings.TrimSpace(req.Description),
		Color:       strings.TrimSpace(req.Color),
		Active:      true,
	}
}

// -----------------------------------------------------------------------------
// GORM scopes (удобные переиспользуемые фильтры)
// -----------------------------------------------------------------------------

func ActiveCategories(db *gorm.DB) *gorm.DB {
	return db.Where("active = ?", true)
}

func CategoriesWithPosts(db *gorm.DB) *gorm.DB {
	return db.Joins("JOIN post_categories pc ON pc.category_id = categories.id").
		Joins("JOIN posts p ON p.id = pc.post_id").
		Group("categories.id").
		Preload("Posts")
}

// -----------------------------------------------------------------------------
// Вспомогательные методы модели
// -----------------------------------------------------------------------------

func (c *Category) IsActive() bool { return c.Active }

func (c *Category) PostCount(db *gorm.DB) (int64, error) {
	if db == nil {
		return 0, errors.New("db is nil")
	}
	cnt := db.Model(c).Association("Posts").Count()
	return cnt, nil // Count() не возвращает ошибку
}

// -----------------------------------------------------------------------------
// Утилита проверки HEX-цвета
// -----------------------------------------------------------------------------

var hexColorRe = regexp.MustCompile(`^#[0-9a-fA-F]{6}$`)

func isHexColor(s string) bool { return hexColorRe.MatchString(s) }
