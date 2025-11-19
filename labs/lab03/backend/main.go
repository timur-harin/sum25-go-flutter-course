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

	// Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	server := &http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Add logging to show server is starting
	log.Println("Starting server on :8080")
	log.Println("API endpoints available at:")
	log.Println("  GET  /api/messages")
	log.Println("  POST /api/messages")
	log.Println("  PUT  /api/messages/{id}")
	log.Println("  DELETE /api/messages/{id}")
	log.Println("  GET  /api/status/{code}")
	log.Println("  GET  /api/health")

	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}
}
