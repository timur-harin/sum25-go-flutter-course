package repository

import (
	"lab04-backend/models"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func setupCategoryRepoTestDB(t *testing.T) (*gorm.DB, *CategoryRepository) {
	db, err := gorm.Open(sqlite.Open("file::memory:?cache=shared"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	require.NoError(t, err, "Failed to connect to database")

	err = db.AutoMigrate(&models.User{}, &models.Post{}, &models.Category{})
	require.NoError(t, err, "Failed to migrate database")

	categoryRepo := NewCategoryRepository(db)

	return db, categoryRepo
}

func TestCategoryRepository(t *testing.T) {
	db, categoryRepo := setupCategoryRepoTestDB(t)
	sqlDB, _ := db.DB()
	defer sqlDB.Close()

	var createdCategory *models.Category

	t.Run("Create category with GORM", func(t *testing.T) {
		category := &models.Category{
			Name:        "Technology",
			Description: "Tech-related posts",
			Color:       "#007bff",
		}
		err := categoryRepo.Create(category)
		assert.NoError(t, err)
		assert.NotZero(t, category.ID)
		assert.NotZero(t, category.CreatedAt)
		assert.Equal(t, "Technology", category.Name)
		createdCategory = category
	})

	t.Run("GetByID with GORM", func(t *testing.T) {
		retrieved, err := categoryRepo.GetByID(createdCategory.ID)
		assert.NoError(t, err)
		assert.Equal(t, createdCategory.Name, retrieved.Name)
		assert.Equal(t, createdCategory.ID, retrieved.ID)

		_, err = categoryRepo.GetByID(999)
		assert.ErrorIs(t, err, gorm.ErrRecordNotFound)
	})

	t.Run("GetAll with GORM", func(t *testing.T) {
		_ = categoryRepo.Create(&models.Category{Name: "Sports"})
		_ = categoryRepo.Create(&models.Category{Name: "Finance"})

		categories, err := categoryRepo.GetAll()
		assert.NoError(t, err)
		assert.Len(t, categories, 3)
		assert.Equal(t, "Finance", categories[0].Name)
		assert.Equal(t, "Sports", categories[1].Name)
		assert.Equal(t, "Technology", categories[2].Name)
	})

	t.Run("Update with GORM", func(t *testing.T) {
		originalUpdatedAt := createdCategory.UpdatedAt
		createdCategory.Name = "Updated Technology"
		time.Sleep(10 * time.Millisecond)

		err := categoryRepo.Update(createdCategory)
		assert.NoError(t, err)

		retrieved, _ := categoryRepo.GetByID(createdCategory.ID)
		assert.Equal(t, "Updated Technology", retrieved.Name)
		assert.True(t, retrieved.UpdatedAt.After(originalUpdatedAt))
	})

	t.Run("FindByName with GORM", func(t *testing.T) {
		retrieved, err := categoryRepo.FindByName("Updated Technology")
		assert.NoError(t, err)
		assert.Equal(t, "Updated Technology", retrieved.Name)

		_, err = categoryRepo.FindByName("Non-existent")
		assert.ErrorIs(t, err, gorm.ErrRecordNotFound)
	})

	t.Run("SearchCategories with GORM", func(t *testing.T) {
		_ = categoryRepo.Create(&models.Category{Name: "Tech News"})

		categories, err := categoryRepo.SearchCategories("Tech", 10)
		assert.NoError(t, err)
		assert.Len(t, categories, 2)
		assert.Equal(t, "Tech News", categories[0].Name)
		assert.Equal(t, "Updated Technology", categories[1].Name)
	})

	t.Run("Count with GORM", func(t *testing.T) {
		count, err := categoryRepo.Count()
		assert.NoError(t, err)
		assert.Equal(t, int64(4), count)
	})

	t.Run("Delete with GORM (Soft Delete)", func(t *testing.T) {
		err := categoryRepo.Delete(createdCategory.ID)
		assert.NoError(t, err)

		_, err = categoryRepo.GetByID(createdCategory.ID)
		assert.ErrorIs(t, err, gorm.ErrRecordNotFound)

		var deletedCat models.Category
		result := db.Unscoped().First(&deletedCat, createdCategory.ID)
		assert.NoError(t, result.Error)
		assert.NotNil(t, deletedCat.DeletedAt)

		count, err := categoryRepo.Count()
		assert.NoError(t, err)
		assert.Equal(t, int64(3), count)
	})

	t.Run("Transaction with GORM", func(t *testing.T) {
		catsToCreate := []*models.Category{
			{Name: "Cat A"}, {Name: "Cat B"},
		}
		err := categoryRepo.CreateWithTransaction(catsToCreate)
		assert.NoError(t, err)

		count, _ := categoryRepo.Count()
		assert.Equal(t, int64(5), count)

		catsToFail := []*models.Category{
			{Name: "Cat C"}, {Name: "Cat A"},
		}
		err = categoryRepo.CreateWithTransaction(catsToFail)
		assert.Error(t, err)

		_, findErr := categoryRepo.FindByName("Cat C")
		assert.ErrorIs(t, findErr, gorm.ErrRecordNotFound)

		countAfterFail, _ := categoryRepo.Count()
		assert.Equal(t, int64(5), countAfterFail)
	})

	t.Run("GetCategoriesWithPosts with GORM Preload", func(t *testing.T) {
		user := models.User{Name: "GORM User", Email: "gorm@test.com"}
		db.Create(&user)
		catWithPost := models.Category{Name: "Category With Posts"}
		db.Create(&catWithPost)
		post := models.Post{UserID: user.ID, Title: "My GORM Post", Content: "..."}
		db.Create(&post)

		db.Model(&catWithPost).Association("Posts").Append(&post)

		categories, err := categoryRepo.GetCategoriesWithPosts()
		assert.NoError(t, err)

		found := false
		for _, category := range categories {
			if category.Name == "Category With Posts" {
				found = true
				require.NotEmpty(t, category.Posts)
				assert.Equal(t, "My GORM Post", category.Posts[0].Title)
			} else {
				assert.Empty(t, category.Posts)
			}
		}
		assert.True(t, found, "Category with post was not found in the results")
	})
}

func TestGORMModelHooks(t *testing.T) {
	_, categoryRepo := setupCategoryRepoTestDB(t)
	sqlDB, _ := categoryRepo.db.DB()
	defer sqlDB.Close()

	t.Run("BeforeCreate hook sets default color", func(t *testing.T) {
		category := &models.Category{Name: "Hook Test Category"}
		err := categoryRepo.Create(category)
		require.NoError(t, err)
		assert.Equal(t, "#CCCCCC", category.Color)
	})

	t.Run("BeforeUpdate hook prevents empty name", func(t *testing.T) {
		category := &models.Category{Name: "Updatable"}
		require.NoError(t, categoryRepo.Create(category))
		err := categoryRepo.db.Model(category).Updates(map[string]interface{}{"name": ""}).Error
		assert.Error(t, err)
		assert.Contains(t, err.Error(), "category name cannot be updated to an empty string")
	})
}

func boolPitr(b bool) *bool {
	return &b
}

func TestGORMScopes(t *testing.T) {
	db, _ := setupCategoryRepoTestDB(t)
	sqlDB, _ := db.DB()
	defer sqlDB.Close()

	catActive := models.Category{Name: "Active Category", Active: boolPitr(true)}
	catInactive := models.Category{Name: "Inactive Category", Active: boolPitr(false)}
	catWithPost := models.Category{Name: "A Category With Post", Active: boolPitr(true)}
	catWithoutPost := models.Category{Name: "A Category Without Post", Active: boolPitr(true)}
	user := models.User{Name: "Scope User", Email: "scope@test.com"}

	require.NoError(t, db.Create(&catActive).Error)
	require.NoError(t, db.Create(&catInactive).Error)
	require.NoError(t, db.Create(&catWithPost).Error)
	require.NoError(t, db.Create(&catWithoutPost).Error)
	require.NoError(t, db.Create(&user).Error)

	post := models.Post{UserID: user.ID, Title: "A Post for Scopes", Content: "..."}
	require.NoError(t, db.Create(&post).Error)
	require.NoError(t, db.Model(&catWithPost).Association("Posts").Append(&post))

	t.Run("ActiveCategories scope", func(t *testing.T) {
		var activeCategories []models.Category
		err := db.Scopes(models.ActiveCategories).Find(&activeCategories).Error
		assert.NoError(t, err)
		assert.Len(t, activeCategories, 3)
		for _, cat := range activeCategories {
			assert.NotNil(t, cat.Active)
			assert.True(t, *cat.Active)
		}
	})

	t.Run("CategoriesWithPosts scope", func(t *testing.T) {
		var categoriesWithPosts []models.Category
		err := db.Scopes(models.CategoriesWithPosts).Find(&categoriesWithPosts).Error
		assert.NoError(t, err)
		require.Len(t, categoriesWithPosts, 1)
		assert.Equal(t, "A Category With Post", categoriesWithPosts[0].Name)
	})
}
