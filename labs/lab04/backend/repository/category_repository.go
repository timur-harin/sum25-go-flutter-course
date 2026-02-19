package repository

import (
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
	err := r.db.First(&category, id).Error
	if err != nil {
		return nil, err
	}
	return &category, nil
}

func (r *CategoryRepository) GetAll() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Order("name").Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) Update(category *models.Category) error {
	return r.db.Save(category).Error
}

func (r *CategoryRepository) Delete(id uint) error {
	return r.db.Delete(&models.Category{}, id).Error
}

func (r *CategoryRepository) FindByName(name string) (*models.Category, error) {
	var category models.Category
	err := r.db.Where("name = ?", name).First(&category).Error
	if err != nil {
		return nil, err
	}
	return &category, nil
}

func (r *CategoryRepository) SearchCategories(query string, limit int) ([]models.Category, error) {
	var categories []models.Category
	err := r.db.
		Where("name LIKE ?", "%"+query+"%").
		Order("name").
		Limit(limit).
		Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) GetCategoriesWithPosts() ([]models.Category, error) {
	var categories []models.Category
	err := r.db.Preload("Posts").Find(&categories).Error
	return categories, err
}

func (r *CategoryRepository) Count() (int64, error) {
	var count int64
	err := r.db.Model(&models.Category{}).Count(&count).Error
	return count, err
}

func (r *CategoryRepository) CreateWithTransaction(categories []models.Category) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		for _, category := range categories {
			if err := tx.Create(&category).Error; err != nil {
				return err
			}
		}
		return nil
	})
}
