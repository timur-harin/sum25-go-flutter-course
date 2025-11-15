package api

import (
	"encoding/json"
	"errors"
	"fmt"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"strings"
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
	h := new(Handler)
	h.storage = storage
	return h
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	// TODO: Create a new mux router
	r := mux.NewRouter()
	// TODO: Add CORS middleware
	r.Use(corsMiddleware)
	// TODO: Create API v1 subrouter with prefix "/api"
	api := r.PathPrefix("/api").Subrouter()
	// TODO: Add the following routes:
	// GET /messages -> h.GetMessages
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	// POST /messages -> h.CreateMessage
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	// PUT /messages/{id} -> h.UpdateMessage
	api.HandleFunc("/messages/{id:[0-9]+}", h.UpdateMessage).Methods("PUT")
	// DELETE /messages/{id} -> h.DeleteMessage
	api.HandleFunc("/messages/{id:[0-9]+}", h.DeleteMessage).Methods("DELETE")
	// GET /status/{code} -> h.GetHTTPStatus
	api.HandleFunc("/status/{code:[0-9]+}", h.GetHTTPStatus).Methods("GET")
	// GET /health -> h.HealthCheck
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	// TODO: Return the router
	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	msgs := h.storage.GetAll()
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    msgs,
	}
	// Write JSON response with status 200
	h.writeJSON(w, 200, response)
	// Handle any errors appropriately
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement CreateMessage handler
	// Parse JSON request body into CreateMessageRequest
	// Validate the request
	var req models.CreateMessageRequest

	if err := h.parseJSON(r, req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}
	// Create message in storage
	msg, _ := h.storage.Create(req.Username, req.Content)
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    msg,
	}
	// Write JSON response with status 201
	h.writeJSON(w, 201, response)
	// Handle validation and storage errors appropriately
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement UpdateMessage handler
	// Extract ID from URL path variables
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 3 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}
	msgID, _ := strconv.Atoi(parts[3])
	// Parse JSON request body into UpdateMessageRequest
	// Validate the request
	var req models.UpdateMessageRequest

	if err := h.parseJSON(r, req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}
	// Update message in storage
	msg, err := h.storage.Update(msgID, req.Content)

	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    msg,
	}
	// Write JSON response with status 200
	h.writeJSON(w, 200, response)
	// Handle validation, parsing, and storage errors appropriately
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 3 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}
	msgID, _ := strconv.Atoi(parts[3])
	// Delete message from storage
	err := h.storage.Delete(msgID)

	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid JSON")
		return
	}
	// Write response with status 204 (No Content)
	response := models.APIResponse{
		Success: true,
		Data:    nil,
	}

	h.writeJSON(w, 204, response)
	// Handle parsing and storage errors appropriately
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetHTTPStatus handler
	// Extract status code from URL path variables
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) < 3 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}
	statusCode, _ := strconv.Atoi(parts[3])
	// Validate status code (must be between 100-599)
	if (statusCode < 100) || (statusCode > 599) {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}
	// Create HTTPStatusResponse with:
	//   - StatusCode: parsed code
	//   - ImageURL: "https://http.cat/{code}"
	//   - Description: HTTP status description
	resp := models.HTTPStatusResponse{
		StatusCode:  statusCode,
		ImageURL:    fmt.Sprintf("https://http.cat/%d.jpg", statusCode),
		Description: getHTTPStatusDescription(statusCode),
	}
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    resp,
	}
	// Write JSON response with status 200
	h.writeJSON(w, 200, response)
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
	resp := models.APIResponse{
		Success: true,
		Data: struct {
			status         string
			message        string
			timestamp      time.Time
			total_messages int
		}{status: "ok",
			message:        "Api is running",
			timestamp:      time.Now(),
			total_messages: h.storage.Count()},
	}
	// Write JSON response with status 200
	h.writeJSON(w, 200, resp)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// TODO: Implement writeJSON helper
	// Set Content-Type header to "application/json"
	w.Header().Set("Content-Type", "application/json")
	// Set status code
	w.WriteHeader(status)
	// Encode data as JSON and write to response
	// Log any encoding errors
	encoder := json.NewEncoder(w)
	if err := encoder.Encode(data); err != nil {
		log.Printf("Error encoding response: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	resp := models.APIResponse{
		Success: false,
		Error:   message,
	}
	// Use writeJSON to send the error response
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	encoder := json.NewEncoder(w)
	if err := encoder.Encode(resp); err != nil {
		log.Printf("Error encoding response: %v", err)
	}
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	decoder := json.NewDecoder(r.Body)
	// Decode into destination interface
	if err := decoder.Decode(&dst); err != nil {
		return errors.New("decode error")
	}
	defer r.Body.Close()
	// Return any decoding errors
	return nil
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	// TODO: Implement getHTTPStatusDescription
	// Return appropriate description for common HTTP status codes
	str := "Unknown Status"
	// Use a switch statement or map to handle:
	// 200: "OK", 201: "Created", 204: "No Content"
	// 400: "Bad Request", 401: "Unauthorized", 404: "Not Found"
	// 500: "Internal Server Error", etc.
	switch code {
	case 200:
		str = "OK"
	case 201:
		str = "Created"
	case 204:
		str = "No Content"
	case 400:
		str = "Bad Request"
	case 401:
		str = "Unauthorized"
	case 404:
		str = "Not Found"
	case 500:
		str = "Internal Server Error"
	}
	// Return "Unknown Status" for unrecognized codes
	return str
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
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
