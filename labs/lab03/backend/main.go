package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"
)

// CORS middleware для ограничения источника (Origin)
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Для preflight-запросов OPTIONS просто возвращаем 200
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	// Создаём хранилище в памяти
	memStorage := storage.NewMemoryStorage()

	// Создаём обработчик API, передаём хранилище
	handler := api.NewHandler(memStorage)

	// Получаем настроенный роутер с маршрутами и middleware
	router := handler.SetupRoutes()

	// Оборачиваем роутер в CORS middleware
	corsRouter := corsMiddleware(router)

	// Конфигурируем сервер с таймаутами
	server := &http.Server{
		Addr:         ":8080",
		Handler:      corsRouter,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Starting server on :8080")

	// Запускаем сервер, логируем ошибки
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}
}
