package repository

import (
	"fmt"
	"lab04-backend/models"

	"gorm.io/gorm"
)

type CategoryRepository struct {
	db *gorm.DB
}

func NewCategoryRepository(gormDB *gorm.DB) *CategoryRepository {
	return &CategoryRepository{db: gormDB}
}

func (r *CategoryRepository) Create(category *models.Category) error {
	return r.db.Create(category).Error
}

func (r *CategoryRepository) GetByID(id uint) (*models.Category, error) {
	var category models.Category
	result := r.db.First(&category, id)
	return &category, result.Error
}

func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Order("name asc").Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) Update(category *models.Category) error {
	return r.db.Save(category).Error
}

func (r *CategoryRepository) Delete(id uint) error {
	return r.db.Delete(&models.Category{}, id).Error
}

func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	result := r.db.Where("name = ?", name).First(&category)
	return &category, result.Error
}

func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Where("name LIKE ?", "%"+query+"%").
		Order("name asc").
		Limit(limit).
		Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	result := r.db.Preload("Posts").Find(&categories)
	return categories, result.Error
}

func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	result := r.db.Model(&models.Category{}).Count(&count)
	return count, result.Error
}

func (r *CategoryRepository) CreateWithTransaction(categories []*models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for _, category := range categories {
			if err := tx.Create(category).Error; err != nil {
				return fmt.Errorf("failed to create category %s: %w", category.Name, err)
			}
		}
		return nil
	})
}
