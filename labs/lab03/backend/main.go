package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	var _memoryStorage = storage.NewMemoryStorage()
	var _handler = api.NewHandler(_memoryStorage)
	var _mux = _handler.SetupRoutes()

	var server = &http.Server{
		Addr:         ":8080",
		Handler:      _mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Server is starting on http://localhost:8080")

	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf(" Server failed to start: %v", err)
	}
}
