package repository

import (
	"fmt"

	"lab04-backend/models"

	"gorm.io/gorm"
)

// CategoryRepository handles database operations for categories using GORM.
type CategoryRepository struct {
	db *gorm.DB
}

// NewCategoryRepository creates a new CategoryRepository with GORM.
func NewCategoryRepository(gormDB *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: gormDB}
}

// -----------------------------------------------------------------------------
// CRUD
// -----------------------------------------------------------------------------

// Create inserts a new category.
func (r *CategoryRepository) Create(category *models.Category) error {
	if category == nil {
		return fmt.Errorf("category is nil")
	}
	return r.db.Create(category).Error
}

// GetByID returns a category by primary key.
func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	err := r.db.First(&category, id).Error
	return &category, err
}

// GetAll returns all categories, отсортированные по имени.
func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Order("name").Find(&categories).Error
	return categories, err
}

// Update сохраняет изменения категории.
func (r *CategoryRepository) Update(category *models.Category) error {
	if category == nil {
		return fmt.Errorf("category is nil")
	}
	return r.db.Save(category).Error
}

// Delete удаляет (мягко) категорию по ID.
func (r *CategoryRepository) Delete(id uint) error {
	return r.db.Delete(&models.Category{}, id).Error
}

// -----------------------------------------------------------------------------
// Поиск / фильтры
// -----------------------------------------------------------------------------

// FindByName ищет категорию по точному совпадению имени.
func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	err := r.db.Where("name = ?", name).First(&category).Error
	return &category, err
}

// SearchCategories ищет категории по подстроке в имени.
func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	tx := r.db.Where("name LIKE ?", "%"+query+"%").Order("name")
	if limit > 0 {
		tx = tx.Limit(limit)
	}
	err := tx.Find(&categories).Error
	return categories, err
}

// GetCategoriesWithPosts возвращает категории с предзагруженными постами.
func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Preload("Posts").Find(&categories).Error
	return categories, err
}

// Count возвращает общее количество категорий (без учёта soft-deleted).
func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	err := r.db.Model(&models.Category{}).Count(&count).Error
	return count, err
}

// -----------------------------------------------------------------------------
// Транзакция
// -----------------------------------------------------------------------------

// CreateWithTransaction создаёт несколько категорий в одной транзакции.
func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for i := range categories {
			if err := tx.Create(&categories[i]).Error; err != nil {
				return err // rollback
			}
		}
		return nil // commit
	})
}
