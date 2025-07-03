package api

import (
	"lab03-backend/storage"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage}
}

func corsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }

        next.ServeHTTP(w, r)
    })
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	// TODO: Create a new mux router
	// TODO: Add CORS middleware
	// TODO: Create API v1 subrouter with prefix "/api"
	// TODO: Add the following routes:
	// GET /messages -> h.GetMessages
	// POST /messages -> h.CreateMessage
	// PUT /messages/{id} -> h.UpdateMessage
	// DELETE /messages/{id} -> h.DeleteMessage
	// GET /status/{code} -> h.GetHTTPStatus
	// GET /health -> h.HealthCheck
	// TODO: Return the router

	r := mux.NewRouter()
	r.Use(corsMiddleware)

	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle any errors appropriately


}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement CreateMessage handler
	// Parse JSON request body into CreateMessageRequest
	// Validate the request
	// Create message in storage
	// Create successful API response
	// Write JSON response with status 201
	// Handle validation and storage errors appropriately
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement UpdateMessage handler
	// Extract ID from URL path variables
	// Parse JSON request body into UpdateMessageRequest
	// Validate the request
	// Update message in storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle validation, parsing, and storage errors appropriately
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	// Delete message from storage
	// Write response with status 204 (No Content)
	// Handle parsing and storage errors appropriately
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetHTTPStatus handler
	// Extract status code from URL path variables
	// Validate status code (must be between 100-599)
	// Create HTTPStatusResponse with:
	//   - StatusCode: parsed code
	//   - ImageURL: "https://http.cat/{code}"
	//   - Description: HTTP status description
	// Create successful API response
	// Write JSON response with status 200
	// Handle parsing and validation errors appropriately
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement HealthCheck handler
	// Create a simple health check response with:
	//   - status: "ok"
	//   - message: "API is running"
	//   - timestamp: current time
	//   - total_messages: count from storage
	// Write JSON response with status 200
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error encoding JSON response: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	response := APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	switch code {
	case http.StatusOK:
		return "OK"
	case http.StatusCreated:
		return "Created"
	case http.StatusNoContent:
		return "No Content"
	case http.StatusBadRequest:
		return "Bad Request"
	case http.StatusUnauthorized:
		return "Unauthorized"
	case http.StatusNotFound:
		return "Not Found"
	case http.StatusInternalServerError:
		return "Internal Server Error"
	default:

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
