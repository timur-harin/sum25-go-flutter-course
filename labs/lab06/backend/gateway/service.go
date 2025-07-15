package gateway

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	pb "lab06-backend/proto"
)

// Service represents the HTTP gateway service
type Service struct {
	calculatorClient pb.CalculatorClient
	router           *mux.Router
}

// OperationRequest represents HTTP request format
type OperationRequest struct {
	A float64 `json:"a"`
	B float64 `json:"b"`
}

// OperationResponse represents HTTP response format
type OperationResponse struct {
	Result    float64 `json:"result"`
	Operation string  `json:"operation"`
	Success   bool    `json:"success"`
	Error     string  `json:"error,omitempty"`
}

// HistoryResponse represents HTTP history response
type HistoryResponse struct {
	Entries []HistoryEntry `json:"entries"`
}

// HistoryEntry represents a single history entry
type HistoryEntry struct {
	Operation string  `json:"operation"`
	A         float64 `json:"a"`
	B         float64 `json:"b"`
	Result    float64 `json:"result"`
	Timestamp int64   `json:"timestamp"`
}

// NewService creates a new gateway service
func NewService(calculatorAddr string) (*Service, error) {
	conn, err := grpc.Dial(calculatorAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	client := pb.NewCalculatorClient(conn)

	s := &Service{
		calculatorClient: client,
		router:           mux.NewRouter(),
	}

	s.setupRoutes()
	return s, nil
}

// setupRoutes configures HTTP routes
func (s *Service) setupRoutes() {
	// Enable CORS middleware for all requests
	s.router.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Set CORS headers for all requests
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept, Origin, X-Requested-With")
			w.Header().Set("Access-Control-Expose-Headers", "Content-Length")

			// Handle preflight OPTIONS requests
			if r.Method == "OPTIONS" {
				w.WriteHeader(http.StatusOK)
				return
			}

			next.ServeHTTP(w, r)
		})
	})

	api := s.router.PathPrefix("/api/v1").Subrouter()

	// Add explicit OPTIONS handler for all routes
	api.HandleFunc("/calculate/{operation}", s.handleOptions).Methods("OPTIONS")
	api.HandleFunc("/history", s.handleOptions).Methods("OPTIONS")
	api.HandleFunc("/health", s.handleOptions).Methods("OPTIONS")

	// Regular API routes
	api.HandleFunc("/calculate/add", s.handleAdd).Methods("POST")
	api.HandleFunc("/calculate/subtract", s.handleSubtract).Methods("POST")
	api.HandleFunc("/calculate/multiply", s.handleMultiply).Methods("POST")
	api.HandleFunc("/calculate/divide", s.handleDivide).Methods("POST")
	api.HandleFunc("/history", s.handleHistory).Methods("GET")
	api.HandleFunc("/health", s.handleHealth).Methods("GET")
}

// GetRouter returns the HTTP router
func (s *Service) GetRouter() *mux.Router {
	return s.router
}

// handleAdd handles addition requests
func (s *Service) handleAdd(w http.ResponseWriter, r *http.Request) {
	var req OperationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := s.calculatorClient.Add(ctx, &pb.OperationRequest{A: req.A, B: req.B})
	if err != nil {
		http.Error(w, "Calculator service error", http.StatusInternalServerError)
		return
	}

	s.writeResponse(w, resp)
}

// handleSubtract handles subtraction requests
func (s *Service) handleSubtract(w http.ResponseWriter, r *http.Request) {
	var req OperationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := s.calculatorClient.Subtract(ctx, &pb.OperationRequest{A: req.A, B: req.B})
	if err != nil {
		http.Error(w, "Calculator service error", http.StatusInternalServerError)
		return
	}

	s.writeResponse(w, resp)
}

// handleMultiply handles multiplication requests
func (s *Service) handleMultiply(w http.ResponseWriter, r *http.Request) {
	var req OperationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := s.calculatorClient.Multiply(ctx, &pb.OperationRequest{A: req.A, B: req.B})
	if err != nil {
		http.Error(w, "Calculator service error", http.StatusInternalServerError)
		return
	}

	s.writeResponse(w, resp)
}

// handleDivide handles division requests
func (s *Service) handleDivide(w http.ResponseWriter, r *http.Request) {
	var req OperationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := s.calculatorClient.Divide(ctx, &pb.OperationRequest{A: req.A, B: req.B})

	// Handle division by zero gracefully
	if err != nil {
		errorResp := &OperationResponse{
			Result:    0,
			Operation: "divide",
			Success:   false,
			Error:     "division by zero",
		}
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(errorResp)
		return
	}

	s.writeResponse(w, resp)
}

// handleHistory handles history requests
func (s *Service) handleHistory(w http.ResponseWriter, r *http.Request) {
	limitStr := r.URL.Query().Get("limit")
	limit := int32(10) // default limit

	if limitStr != "" {
		if parsedLimit, err := strconv.Atoi(limitStr); err == nil && parsedLimit > 0 {
			limit = int32(parsedLimit)
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	resp, err := s.calculatorClient.GetHistory(ctx, &pb.HistoryRequest{Limit: limit})
	if err != nil {
		http.Error(w, "Calculator service error", http.StatusInternalServerError)
		return
	}

	// Convert to HTTP response format
	entries := make([]HistoryEntry, len(resp.Entries))
	for i, entry := range resp.Entries {
		entries[i] = HistoryEntry{
			Operation: entry.Operation,
			A:         entry.A,
			B:         entry.B,
			Result:    entry.Result,
			Timestamp: entry.Timestamp,
		}
	}

	historyResp := &HistoryResponse{Entries: entries}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(historyResp)
}

// handleHealth handles health check requests
func (s *Service) handleHealth(w http.ResponseWriter, r *http.Request) {
	health := map[string]interface{}{
		"status":    "healthy",
		"service":   "calculator-gateway",
		"timestamp": time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(health)
}

// handleOptions handles CORS preflight OPTIONS requests
func (s *Service) handleOptions(w http.ResponseWriter, r *http.Request) {
	// CORS headers are already set by middleware
	w.WriteHeader(http.StatusOK)
}

// writeResponse writes a gRPC response as HTTP JSON
func (s *Service) writeResponse(w http.ResponseWriter, resp *pb.OperationResponse) {
	httpResp := &OperationResponse{
		Result:    resp.Result,
		Operation: resp.Operation,
		Success:   resp.Success,
		Error:     resp.Error,
	}

	w.Header().Set("Content-Type", "application/json")

	if !resp.Success {
		w.WriteHeader(http.StatusBadRequest)
	}

	json.NewEncoder(w).Encode(httpResp)
}
