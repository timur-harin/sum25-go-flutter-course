package main

import (
	"log"
	"net"
	"net/http"
	"sync"

	"google.golang.org/grpc"

	"lab06-backend/calculator"
	"lab06-backend/gateway"
	pb "lab06-backend/proto"
	wsService "lab06-backend/websocket"
)

func main() {
	var wg sync.WaitGroup

	// Start gRPC Calculator Service
	wg.Add(1)
	go func() {
		defer wg.Done()
		startCalculatorService()
	}()

	// Start Gateway HTTP Service
	wg.Add(1)
	go func() {
		defer wg.Done()
		startGatewayService()
	}()

	// Start WebSocket Service
	wg.Add(1)
	go func() {
		defer wg.Done()
		startWebSocketService()
	}()

	log.Println("All services started successfully!")
	log.Println("Calculator gRPC service: localhost:50051")
	log.Println("Gateway HTTP service: http://localhost:8080")
	log.Println("WebSocket service: ws://localhost:8081/ws")

	wg.Wait()
}

// startCalculatorService starts the gRPC calculator service
func startCalculatorService() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("Failed to listen on :50051: %v", err)
	}

	server := grpc.NewServer()
	calculatorService := calculator.NewService()

	pb.RegisterCalculatorServer(server, calculatorService)

	log.Println("Calculator gRPC service starting on :50051")
	if err := server.Serve(lis); err != nil {
		log.Fatalf("Failed to serve calculator gRPC service: %v", err)
	}
}

// startGatewayService starts the HTTP gateway service
func startGatewayService() {
	gatewayService, err := gateway.NewService("localhost:50051")
	if err != nil {
		log.Fatalf("Failed to create gateway service: %v", err)
	}

	server := &http.Server{
		Addr:    ":8080",
		Handler: gatewayService.GetRouter(),
	}

	log.Println("Gateway HTTP service starting on :8080")
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to serve gateway HTTP service: %v", err)
	}
}

// startWebSocketService starts the WebSocket service
func startWebSocketService() {
	wsServiceInstance := wsService.NewService()

	mux := http.NewServeMux()
	mux.HandleFunc("/ws", wsServiceInstance.GetHandler())
	mux.HandleFunc("/stats", wsServiceInstance.GetStatsHandler())

	// Add CORS middleware
	corsHandler := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}

			next.ServeHTTP(w, r)
		})
	}

	server := &http.Server{
		Addr:    ":8081",
		Handler: corsHandler(mux),
	}

	log.Println("WebSocket service starting on :8081")
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("Failed to serve WebSocket service: %v", err)
	}
}
