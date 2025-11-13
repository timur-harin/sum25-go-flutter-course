package main

import (
    "lab03-backend/api"
    "lab03-backend/storage"
    "log"
    "net/http"
    "os"
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
	
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    memStore := storage.NewMemoryStorage()
    handler := api.NewHandler(memStore)
    router := handler.SetupRoutes()

    log.Printf("Server started at http://localhost:%s", port)
    log.Fatal(http.ListenAndServe(":"+port, router))
}