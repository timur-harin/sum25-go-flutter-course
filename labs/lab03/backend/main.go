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

	// Add logging to show server is starting
	log.Printf("Starting server on %s\n", server.Addr)
	log.Println("Server configured with:")
	log.Printf("  ReadTimeout: %s", server.ReadTimeout)
	log.Printf("  WriteTimeout: %s", server.WriteTimeout)
	log.Printf("  IdleTimeout: %s", server.IdleTimeout)
	log.Println("API endpoints available at http://localhost:8080/api/")
	log.Println("Press Ctrl+C to stop the server")

	// Start the server and handle any errors
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Could not start server: %v\n", err)
	}
}