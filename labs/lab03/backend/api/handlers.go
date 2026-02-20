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
	return &Handler{Storage: storage}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	// TODO: Create a new mux router
	Router := mux.NewRouter()
	// TODO: Add CORS middleware
	// TODO: Create API v1 subrouter with prefix "/api"
	ApiSubRouter := Router.PathPrefix("/api").Subrouter()
	// TODO: Add the following routes:
	ApiSubRouter.Use(corsMiddleware)
	// GET /messages -> h.GetMessages
	ApiSubRouter.HandleFunc("/messages", h.GetMessages).Methods("GET")
	// POST /messages -> h.CreateMessage
	ApiSubRouter.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	// PUT /messages/{id} -> h.UpdateMessage
	ApiSubRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	// DELETE /messages/{id} -> h.DeleteMessage
	ApiSubRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	// GET /status/{code} -> h.GetHTTPStatus
	ApiSubRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	// GET /health -> h.HealthCheck
	ApiSubRouter.HandleFunc("/health", h.HealthCheck).Methods("GET")
	ApiSubRouter.HandleFunc("/cat/{code}", h.ProxyCatImage).Methods("GET")
	// TODO: Return the router
	return Router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	messages := h.Storage.GetAll()
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    messages,
	}
	// Write JSON response with status 200
	h.writeJSON(w, http.StatusOK, response)
	// Handle any errors appropriately
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement CreateMessage handler
	// Parse JSON request body into CreateMessageRequest
	var CMreq models.CreateMessageRequest
	err := h.parseJSON(r, &CMreq)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	// Validate the request
	err = CMreq.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	// Create message in storage
	msg, err := h.Storage.Create(CMreq.Username, CMreq.Content)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	// Create successful API response
	// Write JSON response with status 201
	response := models.APIResponse{
		Success: true,
		Data:    msg,
	}
	// Handle validation and storage errors appropriately
	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement UpdateMessage handler
	// Extract ID from URL path variables
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	// Parse JSON request body into UpdateMessageRequest
	var request models.UpdateMessageRequest
	if err := h.parseJSON(r, &request); err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	// Validate the request
	err = request.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	// Update message in storage
	updatedMsg, err := h.Storage.Update(id, request.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	// Create successful API response
	response := models.APIResponse{
		Success: true,
		Data:    updatedMsg,
	}
	// Write JSON response with status 200
	h.writeJSON(w, http.StatusOK, response)
	// Handle validation, parsing, and storage errors appropriately
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement DeleteMessage handler
	// Extract ID from URL path variables
	vars := mux.Vars(r)
	idStr, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	// Delete message from storage
	err = h.Storage.Delete(id)
	if err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	// Write response with status 204 (No Content)
	w.WriteHeader(http.StatusNoContent)
	// Handle parsing and storage errors appropriately
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetHTTPStatus handler
	// Extract status code from URL path variables
	vars := mux.Vars(r)
	codeStr, ok := vars["code"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	code, err := strconv.Atoi(codeStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	// Validate status code (must be between 100-599)
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Code must be between 100–599")
		return
	}
	// Create HTTPStatusResponse with:
	//   - StatusCode: parsed code
	//   - ImageURL: "https://http.cat/{code}"

	//   - Description: HTTP status description
	localURL := fmt.Sprintf("http://localhost:8080/api/cat/%d", code)
	response := models.APIResponse{
		Success: true,
		Data: models.HTTPStatusResponse{
			StatusCode:  code,
			ImageURL:    localURL,
			Description: getHTTPStatusDescription(code),
		},
	}
	// Create successful API response
	// Write JSON response with status 200
	h.writeJSON(w, http.StatusOK, response)
	// Handle parsing and validation errors appropriately
}

func (h *Handler) ProxyCatImage(w http.ResponseWriter, r *http.Request) {
	// Extract status code from URL path variables
	vars := mux.Vars(r)
	codeStr, ok := vars["code"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}
	code, err := strconv.Atoi(codeStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, getHTTPStatusDescription(http.StatusBadRequest))
		return
	}

	// Construct the HTTP Cats URL
	catURL := fmt.Sprintf("https://http.cat/%d.jpg", code)

	// Make request to http.cat
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Get(catURL)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "Failed to fetch image from http.cat")
		return
	}
	defer resp.Body.Close()

	// Check if the status code is supported by http.cat
	if resp.StatusCode != http.StatusOK {
		h.writeError(w, resp.StatusCode, getHTTPStatusDescription(resp.StatusCode))
		return
	}

	// Set response headers to match http.cat's response
	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.Header().Set("Content-Length", resp.Header.Get("Content-Length"))
	w.WriteHeader(http.StatusOK)

	// Stream the image data to the client
	_, err = io.Copy(w, resp.Body)
	if err != nil {
		if !isHeaderWritten(w) {
			h.writeError(w, http.StatusInternalServerError, "Failed to stream image")
		}
		return
	}
}

// HealthCheck handles GET /api/health
type HealthCheckResponse struct {
	Status        string    `json:"status"`
	Message       string    `json:"message"`
	Timestamp     time.Time `json:"timestamp"`
	TotalMessages int       `json:"total_messages"`
}

func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement HealthCheck handler
	// Create a simple health check response with:
	//   - status: "ok"
	//   - message: "API is running"
	//   - timestamp: current time
	//   - total_messages: count from storage
	response := models.APIResponse{
		Success: true,
		Data: HealthCheckResponse{
			Status:        "healthy",
			Message:       "API is running",
			Timestamp:     time.Now(),
			TotalMessages: h.Storage.Count(),
		},
	}
	// Write JSON response with status 200
	h.writeJSON(w, http.StatusOK, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// TODO: Implement writeJSON helper
	// Set Content-Type header to "application/json"
	// Set status code
	if !isHeaderWritten(w) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(status)
	}
	// Encode data as JSON and write to response
	err := json.NewEncoder(w).Encode(data)
	// Log any encoding errors
	if err != nil {
		log.Printf("JSON Error encoding : %v", err)
		if isHeaderWritten(w) {
			return
		}
		h.writeError(w, http.StatusInternalServerError, getHTTPStatusDescription(http.StatusInternalServerError))
	}
}

func isHeaderWritten(w http.ResponseWriter) bool {
	type headerWriter interface {
		Written() bool
	}
	if hw, ok := w.(headerWriter); ok {
		return hw.Written()
	}
	return false
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	response := models.APIResponse{
		Success: false,
		Error:   message,
	}
	// Use writeJSON to send the error response
	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	decoder := json.NewDecoder(r.Body)
	// Decode into destination interface
	err := decoder.Decode(dst)
	// Return any decoding errors
	if err != nil {
		return err
	}
	return nil
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	// TODO: Implement getHTTPStatusDescription
	// Return appropriate description for common HTTP status codes
	// Use a switch statement or map to handle:
	// 200: "OK", 201: "Created", 204: "No Content"
	// 400: "Bad Request", 401: "Unauthorized", 404: "Not Found"
	// 500: "Internal Server Error", etc.
	statuses := map[int]string{
		200: "OK",
		201: "Created",
		204: "No Content",
		400: "Bad Request",
		401: "Unauthorized",
		404: "Not Found",
		500: "Internal Server Error",
	}
	description, ok := statuses[code]
	if ok {
		return description
	}
	// Return "Unknown Status" for unrecognized codes
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
		origin := r.Header.Get("Origin")
		if origin == "" {
			origin = "*"
		}
		w.Header().Set("Access-Control-Allow-Origin", origin)
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept, Origin")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
