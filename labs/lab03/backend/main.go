package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	// Создаем новый экземпляр памяти для хранения сообщений
	memStorage := storage.NewMemoryStorage()

	// Создаем новый обработчик API с этим хранилищем
	handler := api.NewHandler(memStorage)

	// Настраиваем маршруты
	router := handler.SetupRoutes()

	// Конфигурируем HTTP сервер
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Логируем старт сервера
	log.Println("Starting server on :8080")

	// Запускаем сервер и логируем ошибку, если она возникнет
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
