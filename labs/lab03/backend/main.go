package main

import (
	"lab03-backend/api"
	"lab03-backend/storage"
	"log"
	"net/http"
	"time"
)

func main() {
	// TODO: Create a new memory storage instance
	// TODO: Create a new API handler with the storage
	// TODO: Setup routes using the handler
	// TODO: Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	// TODO: Add logging to show server is starting
	// TODO: Start the server and handle any errors
	storage := storage.NewMemoryStorage()
	handler := api.NewHandler(storage)
	router := handler.SetupRoutes()
	server := &http.Server{
		Handler:      router,
		Addr:         ":8080",
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Println("Registered routes:")
	log.Println("GET    /api/messages        -> GetMessages")
	log.Println("POST   /api/messages        -> CreateMessage")
	log.Println("PUT    /api/messages/{id}   -> UpdateMessage")
	log.Println("DELETE /api/messages/{id}   -> DeleteMessage")
	log.Println("GET    /api/status/{code}   -> GetHTTPStatus")
	log.Println("GET    /api/health          -> HealthCheck")
	log.Println("Starting server on http://localhost:8080")
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
