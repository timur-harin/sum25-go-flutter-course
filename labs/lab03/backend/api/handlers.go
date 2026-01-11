package api

import (
	"encoding/json"
	"fmt"
	"io"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	// TODO: Add storage field of type *storage.MemoryStorage
	Storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	// TODO: Return a new Handler instance with provided storage
	handler := new(Handler)
	handler.Storage = storage
	return handler
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
	mux_router := mux.NewRouter()
	mux_router.Use(corsMiddleware)

	apiRouter := mux_router.PathPrefix("/api").Subrouter()
	apiRouter.HandleFunc("/messages", h.GetMessages).Methods("GET")
	apiRouter.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	apiRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	apiRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	apiRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	apiRouter.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return mux_router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle any errors appropriately
	messages := h.Storage.GetAll()
	h.writeJSON(w, 200, models.APIResponse{
		Success: true,
		Data:    messages,
	})
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
	var req models.CreateMessageRequest

	err := h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	err = req.Validate()
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	message, err := h.Storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, 500, "Server errors")
		return
	}

	h.writeJSON(w, 201, models.APIResponse{
		Success: true,
		Data:    message,
	})
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
	id_url := mux.Vars(r)["id"]
	id, err := strconv.Atoi(id_url)
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	var req models.UpdateMessageRequest
	err = h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	err = req.Validate()
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	updated, err := h.Storage.Update(id, req.Content)
	if err != nil {
		h.writeError(w, 404, "Message not found")
		return
	}

	h.writeJSON(w, 200, models.APIResponse{
		Success: true,
		Data:    updated,
	})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	// Delete message from storage
	// Write response with status 204 (No Content)
	// Handle parsing and storage errors appropriately
	id_url := mux.Vars(r)["id"]
	id, err := strconv.Atoi(id_url)
	if err != nil {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	err = h.Storage.Delete(id)
	if err != nil {
		h.writeError(w, 404, "Message not found")
		return
	}

	w.WriteHeader(204)
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

	code_url := mux.Vars(r)["code"]
	code, err := strconv.Atoi(code_url)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, 400, "Invalid request data")
		return
	}

	resp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("https://http.cat/%d", code),
		Description: getHTTPStatusDescription(code),
	}

	h.writeJSON(w, 200, models.APIResponse{
		Success: true,
		Data:    resp,
	})
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
	resp := map[string]interface{}{
		"status":         "healthy",
		"message":        "API is running",
		"timestamp":      time.Now(),
		"total_messages": h.Storage.Count(),
	}
	h.writeJSON(w, 200, models.APIResponse{
		Success: true,
		Data:    resp,
	})
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// TODO: Implement writeJSON helper
	// Set Content-Type header to "application/json"
	// Set status code
	// Encode data as JSON and write to response
	// Log any encoding errors
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	err := json.NewEncoder(w).Encode(data)
	if err != nil {
		log.Printf("[ERROR] Cant encode JSON: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	// Use writeJSON to send the error response
	h.writeJSON(w, status, models.APIResponse{
		Success: false,
		Error:   message,
	})
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	// Decode into destination interface
	// Return any decoding errors
	body, err := io.ReadAll(r.Body)
	if err != nil {
		return err
	}
	return json.Unmarshal(body, dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	// TODO: Implement getHTTPStatusDescription
	// Return appropriate description for common HTTP status codes
	// Use a switch statement or map to handle:
	// 200: "OK", 201: "Created", 204: "No Content"
	// 400: "Bad Request", 401: "Unauthorized", 404: "Not Found"
	// 500: "Internal Server Error", etc.
	// Return "Unknown Status" for unrecognized codes
	switch code {
	case 200:
		return "OK"
	case 201:
		return "Created"
	case 204:
		return "No Content"
	case 400:
		return "Bad request"
	case 404:
		return "Not Found"
	case 500:
		return "Internal Server Error"
	}
	return "Unknown Status"
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	// TODO: Implement CORS middleware
	// Set the following headers:
	// Access-Control-Allow-Origin: *
	// Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
	// Access-Control-Allow-Headers: Content-Type, Authorization
	// Handle OPTIONS preflight requests
	// Call next handler for non-OPTIONS requests
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// TODO: Implement CORS logic here
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(204)
			return
		}
		next.ServeHTTP(w, r)
	})
}
