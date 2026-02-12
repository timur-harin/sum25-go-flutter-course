package main

import (
	"log"
	"net/http"
	"time"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	// Create a new memory storage instance
	memStorage := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(memStorage)

	// Setup routes using the handler
	router := handler.SetupRoutes()

	// Configure server
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Starting server on :8080...")
	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
