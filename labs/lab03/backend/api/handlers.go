package api

import (
	"encoding/json"
	"lab03-backend/models"
	"lab03-backend/storage"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

// HTTPStatusResponse represents the response for HTTP status requests
var HTTPDescription = map[int]string{
	200: "OK",
	201: "Created",
	204: "No Content",
	400: "Bad Request",
	401: "Unauthorized",
	404: "Not Found",
	500: "Internal Server Error",
}

// Handler holds the storage instance
type Handler struct {
	// TODO: Add storage field of type *storage.MemoryStorage
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	// TODO: Return a new Handler instance with provided storage
	return &Handler{
		storage: storage,
	}
}

// *mux.Router
func (h *Handler) SetupRoutes() http.Handler {
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
	router := mux.NewRouter()
	api := router.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods(http.MethodGet)
	api.HandleFunc("/messages", h.CreateMessage).Methods(http.MethodPost)
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods(http.MethodPut)
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods(http.MethodDelete)
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods(http.MethodGet)
	api.HandleFunc("/health", h.HealthCheck).Methods(http.MethodGet)
	return corsMiddleware(router)
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle any errors appropriately
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data:    h.storage.GetAll(),
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
	var request models.CreateMessageRequest
	err := h.parseJSON(r, &request)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	err = request.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	h.storage.Create(request.Username, request.Content)
	h.writeJSON(w, 201, models.APIResponse{
		Success: true,
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
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "id is required")
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id format")
		return
	}
	var request models.UpdateMessageRequest
	err = h.parseJSON(r, &request)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	err = request.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	h.storage.Update(id, request.Content)
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
	})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	// Delete message from storage
	// Write response with status 204 (No Content)
	// Handle parsing and storage errors appropriately
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "id is required")
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id format")
		return
	}
	err = h.storage.Delete(id)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	h.writeJSON(w, 204, nil)
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
	vars := mux.Vars(r)
	codeStr, ok := vars["code"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "status code is required")
		return
	}
	code, err := strconv.Atoi(codeStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid status code format")
		return
	}
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{
		Success: true,
		Data: models.HTTPStatusResponse{
			StatusCode:  code,
			ImageURL:    "localhost:8080/api/cat/" + strconv.Itoa(code),
			Description: HTTPDescription[code],
		},
	})
}

// HealthCheckResponse represents the response for health check requests
type HealthCheckResponse struct {
	Status        string    `json:"status"`
	Message       string    `json:"message"`
	Timestamp     time.Time `json:"timestamp"`
	TotalMessages int       `json:"total_messages"`
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
	h.writeJSON(w, http.StatusOK, HealthCheckResponse{
		Status:        "healthy",
		Message:       "API is running",
		Timestamp:     time.Now(),
		TotalMessages: h.storage.Count(),
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
		log.Println("Error encoding JSON response:", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	// Use writeJSON to send the error response
	res := models.APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, res)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	// Decode into destination interface
	// Return any decoding errors
	err := json.NewDecoder(r.Body).Decode(dst)
	return err
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
	description, ok := HTTPDescription[code]
	if ok {
		return description
	}
	return "Unknown Status"
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
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
