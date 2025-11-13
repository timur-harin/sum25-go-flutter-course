package api

import (
	"encoding/json"
    "fmt"
	"lab03-backend/models"
	"lab03-backend/storage"
	"net/http"
	"strconv"
    "time"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	// TODO: Add storage field of type *storage.MemoryStorage
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	// TODO: Return a new Handler instance with provided storage
	return &Handler{storage: storage}
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
	messages := h.storage.GetAll()
    h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: messages})
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
    if err := h.parseJSON(r, &req); err != nil {
        h.writeError(w, http.StatusBadRequest, "Invalid JSON")
        return
    }

    if err := req.Validate(); err != nil {
        h.writeError(w, http.StatusBadRequest, err.Error())
        return
    }

    msg, err := h.storage.Create(req.Username, req.Content)
    if err != nil {
        h.writeError(w, http.StatusInternalServerError, "Failed to create message")
        return
    }

    h.writeJSON(w, http.StatusCreated, models.APIResponse{Success: true, Data: msg})
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
	idStr := mux.Vars(r)["id"]
    id, err := strconv.Atoi(idStr)
    if err != nil || id < 1 {
        h.writeError(w, http.StatusBadRequest, "Invalid ID")
        return
    }

    var req models.UpdateMessageRequest
    if err := h.parseJSON(r, &req); err != nil {
        h.writeError(w, http.StatusBadRequest, "Invalid JSON")
        return
    }

    if err := req.Validate(); err != nil {
        h.writeError(w, http.StatusBadRequest, err.Error())
        return
    }

    msg, err := h.storage.Update(id, req.Content)
    if err != nil {
        h.writeError(w, http.StatusNotFound, "Message not found")
        return
    }

    h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msg})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	// Delete message from storage
	// Write response with status 204 (No Content)
	// Handle parsing and storage errors appropriately
	idStr := mux.Vars(r)["id"]
    id, err := strconv.Atoi(idStr)
    if err != nil || id < 1 {
        h.writeError(w, http.StatusBadRequest, "Invalid ID")
        return
    }

    if err := h.storage.Delete(id); err != nil {
        h.writeError(w, http.StatusNotFound, "Message not found")
        return
    }

    w.WriteHeader(http.StatusNoContent)
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
	codeStr := mux.Vars(r)["code"]
    code, err := strconv.Atoi(codeStr)
    if err != nil || code < 100 || code > 599 {
        h.writeError(w, http.StatusBadRequest, "Invalid status code")
        return
    }

    resp := models.HTTPStatusResponse{
        StatusCode:  code,
        ImageURL:    fmt.Sprintf("https://http.cat/%d", code),
        Description: getHTTPStatusDescription(code),
    }

    h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: resp})
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
	response := map[string]interface{}{
        "status":         "ok",
        "message":        "API is running",
        "timestamp":      time.Now().UTC(),
        "total_messages": h.storage.Count(),
    }

    h.writeJSON(w, http.StatusOK, response)
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
    if err := json.NewEncoder(w).Encode(data); err != nil {
        http.Error(w, "Failed to encode response", http.StatusInternalServerError)
    }
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	// Use writeJSON to send the error response
	h.writeJSON(w, status, models.APIResponse{Success: false, Error: message})
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	// Decode into destination interface
	// Return any decoding errors
	decoder := json.NewDecoder(r.Body)
    decoder.DisallowUnknownFields()
    return decoder.Decode(dst)
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
	return http.StatusText(code)
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
		w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        next.ServeHTTP(w, r)
	})
}
