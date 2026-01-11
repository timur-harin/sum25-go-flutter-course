package main

import (
	"fmt"
	"log"
	"net/http"

	"lab03-backend/api"
	"lab03-backend/storage"
)

func main() {
	// TODO: Create a new memory storage instance
	memory := storage.NewMemoryStorage()
	// TODO: Create a new API handler with the storage

	handler := api.NewHandler(memory)

	// TODO: Setup routes using the handler

	router := handler.SetupRoutes()



	server := http.Server{
		Addr: ":8080",
		Handler: router,
		ReadTimeout: 15,
		WriteTimeout: 15,
		IdleTimeout: 60,
	}

	fmt.Println("Starting")

	if err := server.ListenAndServe();err != nil {
		panic(err)
	}

	// TODO: Configure server with:
	//   - Address: ":8080"
	//   - Handler: the router
	//   - ReadTimeout: 15 seconds
	//   - WriteTimeout: 15 seconds
	//   - IdleTimeout: 60 seconds
	// TODO: Add logging to show server is starting
	// TODO: Start the server and handle any errors

	log.Println("TODO: Implement main function")
}
