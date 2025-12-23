package main

import (
	api2 "lab03-backend/api"
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
	log.Println("Initializing memory storage..")
	ms := storage.NewMemoryStorage()
	log.Println("Starting web server")
	handler := api2.NewHandler(ms)
	routes := handler.SetupRoutes()
	var port = "8080"
	server := &http.Server{
		Addr:         ":" + port,
		Handler:      routes,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}
	log.Println("Listen and serve on port: " + port)
	log.Fatal(server.ListenAndServe())
}
