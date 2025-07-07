package main

import (
	"context"
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	// Create a new memory storage instance
	memoryStorage := storage.NewMemoryStorage()

	// Create a new API handler with the storage
	handler := api.NewHandler(memoryStorage)

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
	log.Printf("Starting server on %s", server.Addr)
	log.Println("API endpoints:")
	log.Println("  GET    /api/messages       - Get all messages")
	log.Println("  POST   /api/messages       - Create new message")
	log.Println("  PUT    /api/messages/{id}  - Update message")
	log.Println("  DELETE /api/messages/{id}  - Delete message")
	log.Println("  GET    /api/status/{code}  - Get HTTP status info")
	log.Println("  GET    /api/cat/{code}     - Get HTTP status cat image")
	log.Println("  GET    /api/health         - Health check")

	// Start the server in a goroutine
	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server failed to start: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down server...")

	// Create a context with timeout for graceful shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Shutdown server gracefully
	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited")
}
