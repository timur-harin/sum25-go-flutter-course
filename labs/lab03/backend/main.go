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
	memStore := storage.NewMemoryStorage()
	apiHandler := api.NewHandler(memStore)
	router := apiHandler.SetupRoutes()
	server := http.Server{
		Addr:         ":8080",
		Handler:      router,
		ReadTimeout:  time.Second * 15,
		WriteTimeout: time.Second * 15,
		IdleTimeout:  time.Minute * 1,
	}

	log.Println("Server starting")
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
