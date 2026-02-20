package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	// Create a new memory storage instance
	storage := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(storage)

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

	// Log server startup
	log.Println("Starting server on :8080")
	log.Printf("API endpoints:")
	log.Printf("  GET    /api/messages")
	log.Printf("  POST   /api/messages")
	log.Printf("  PUT    /api/messages/{id}")
	log.Printf("  DELETE /api/messages/{id}")
	log.Printf("  GET    /api/status/{code}")
	log.Printf("  GET    /api/health")

	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}
}
