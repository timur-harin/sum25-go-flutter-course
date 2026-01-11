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
	ms := new(storage.MemoryStorage)
	// TODO: Create a new API handler with the storage
	apiHandler := api.NewHandler(ms)
	// TODO: Setup routes using the handler
	router := apiHandler.SetupRoutes()
	// TODO: Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	server := &http.Server{
		Addr:         "0.0.0.0:8080",
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	// TODO: Add logging to show server is starting
	log.Println("Server is running on :8080")

	// TODO: Start the server and handle any errors
	server.ListenAndServe()
}
