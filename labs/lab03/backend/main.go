package main

import (
	"log"
	"net/http"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	log.Println("Starting REST API Chat Server...")

	// Initialize storage
	store := storage.NewMemoryStorage()

	// Initialize handler with storage
	handler := api.NewHandler(store)

	// Setup routes
	router := handler.SetupRoutes()

	// Define server address
	addr := ":8080"
	log.Printf("Server listening on %s", addr)

	// Start the server
	if err := http.ListenAndServe(addr, router); err != nil {
		log.Fatalf("Could not start server: %v\n", err)
	}
}
