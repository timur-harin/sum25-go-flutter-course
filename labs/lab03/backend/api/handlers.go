package api

import (
	"encoding/json"
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
	router := mux.NewRouter()
	// TODO: Add CORS middleware
	router.Use(corsMiddleware)
	router.Use(mux.CORSMethodMiddleware(router))
	// TODO: Create API v1 subrouter with prefix "/api"
	api := router.PathPrefix("/api").Subrouter()
	// TODO: Add the following routes:
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	// GET /health -> h.HealthCheck
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	// TODO: Return the router
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	response := h.storage.GetAll()
	h.writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"data":    response,
	})
	// Get all messages from storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle any errors appropriately
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement CreateMessage handler
	type CreateMessageRequest struct {
		Username string `json:"username"`
		Content  string `json:"content"`
	}

	var req CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON body")
		return
	}

	if req.Username == "" || req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "Username and content are required")
		return
	}

	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to create message")
		return
	}

	h.writeJSON(w, http.StatusCreated, map[string]interface{}{
		"success": true,
		"id":      msg.ID,
	})
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
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing message ID")
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	type UpdateMessageRequest struct {
		Content string `json:"content"`
	}

	var req UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON body")
		return
	}

	if req.Content == "" {
		h.writeError(w, http.StatusBadRequest, "Content is required")
		return
	}

	_, err = h.storage.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to update message")
		}
		return
	}

	h.writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
	})
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
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing message ID")
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	err = h.storage.Delete(id)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, "Message not found")
		} else {
			h.writeError(w, http.StatusInternalServerError, "Failed to delete message")
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
	// Extract ID from URL path variables
	// Delete message from storage
	// Write response with status 204 (No Content)
	// Handle parsing and storage errors appropriately
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetHTTPStatus handler
	vars := mux.Vars(r)
	codeStr, ok := vars["code"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "Missing status code")
		return
	}

	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	resp := map[string]interface{}{
		"success":     true,
		"statusCode":  code,
		"imageURL":    "https://http.cat/" + codeStr,
		"description": getHTTPStatusDescription(code),
	}

	h.writeJSON(w, http.StatusOK, resp)
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
	count := h.storage.Count()

	resp := map[string]interface{}{
		"status":         "ok",
		"message":        "API is running",
		"timestamp":      time.Now().Format(time.RFC3339),
		"total_messages": count,
	}

	h.writeJSON(w, http.StatusOK, resp)
	// Create a simple health check response with:
	//   - status: "ok"
	//   - message: "API is running"
	//   - timestamp: current time
	//   - total_messages: count from storage
	// Write JSON response with status 200
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// TODO: Implement writeJSON helper
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		// Log encoding errors if needed
	}
	// Set Content-Type header to "application/json"
	// Set status code
	// Encode data as JSON and write to response
	// Log any encoding errors
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	resp := map[string]interface{}{
		"success": false,
		"error":   message,
	}
	h.writeJSON(w, status, resp)
	// Create APIResponse with Success: false and Error: message
	// Use writeJSON to send the error response
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	decoder := json.NewDecoder(r.Body)
	defer r.Body.Close()
	return decoder.Decode(dst)
	// Create JSON decoder from request body
	// Decode into destination interface
	// Return any decoding errors
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	// TODO: Implement getHTTPStatusDescription
	switch code {
	case 200:
		return "OK"
	case 201:
		return "Created"
	case 204:
		return "No Content"
	case 400:
		return "Bad Request"
	case 401:
		return "Unauthorized"
	case 404:
		return "Not Found"
	case 500:
		return "Internal Server Error"
	default:
		return "Unknown Status"
	}
	// Return appropriate description for common HTTP status codes
	// Use a switch statement or map to handle:
	// 200: "OK", 201: "Created", 204: "No Content"
	// 400: "Bad Request", 401: "Unauthorized", 404: "Not Found"
	// 500: "Internal Server Error", etc.
	// Return "Unknown Status" for unrecognized codes
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
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
