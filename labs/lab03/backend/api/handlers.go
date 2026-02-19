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
func handleCatImage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code := vars["code"]
	imageURL := fmt.Sprintf("https://http.cat/%s", code)

	resp, err := http.Get(imageURL)
	if err != nil {
		http.Error(w, "Failed to fetch image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// Set content type
	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	w.WriteHeader(resp.StatusCode)
	_, err = io.Copy(w, resp.Body)
	if err != nil {
		log.Printf("Failed to write image body: %v", err)
	}
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
	router := mux.NewRouter()                                 // creating a new router from the Gorilla Mux package to controll the traffic for incomming HTTP requests
	router.Use(corsMiddleware)                                // custom function that adds CORS headers, so that frontend can talk to the backend running on localhost
	api := router.PathPrefix("/api").Subrouter()              // creates a sub-router for all paths that start with /api
	api.HandleFunc("/messages", h.GetMessages).Methods("GET") // registers a route on that /api subrouter
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	api.HandleFunc("/cat/{code}", handleCatImage).Methods("GET", "OPTIONS")
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	// Get all messages from storage
	// Create successful API response
	// Write JSON response with status 200
	// Handle any errors appropriately
	messages := h.storage.GetAll()                        // fetches all messages from storage
	h.writeJSON(w, http.StatusOK, map[string]interface{}{ // writing JSON to the response writer
		"success": true,
		"data":    messages,
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
	var req models.CreateMessageRequest          // declaring a struct variable that expects JSON with username and content fields
	if err := h.parseJSON(r, &req); err != nil { // attempts to parse the request body into the req struct
		h.writeError(w, http.StatusBadRequest, "invalid JSON")
		return
	}
	if err := req.Validate(); err != nil { // checking that Username and Content is not empty
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Create(req.Username, req.Content) // store the message in memory
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "could not create message")
		return
	}
	log.Printf("Created message: %+v\n", msg)
	h.writeJSON(w, http.StatusCreated, map[string]interface{}{ // send success response
		"success": true,
		"data":    msg,
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
	userID, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "missing message ID in URL")
		return
	}
	id, err := strconv.Atoi(userID)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON body")
		return
	}
	if err := req.Validate(); err != nil { // checking that Username and Content is not empty
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	updatedMsg, err := h.storage.Update(id, req.Content) // update the message in memory
	if err != nil {
		h.writeError(w, http.StatusNotFound, "message not found")
		return
	}
	h.writeJSON(w, http.StatusOK, map[string]interface{}{ // return success response
		"success": true,
		"data":    updatedMsg,
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
	userID, ok := vars["id"]
	if !ok {
		h.writeError(w, http.StatusBadRequest, "missing message ID in URL")
		return
	}
	id, err := strconv.Atoi(userID)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	err = h.storage.Delete(id) // deletes the message with the given id
	if err != nil {            // the message was not found
		h.writeError(w, http.StatusNotFound, "message not found")
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

	vars := mux.Vars(r)
	codeStatusStr, ok := vars["code"]
	if !ok { // checking whether status code is missed or not
		h.writeError(w, http.StatusBadRequest, "missing status code")
		return
	}
	codeStatus, err := strconv.Atoi(codeStatusStr)          // converts string into int type
	if err != nil || codeStatus < 100 || codeStatus > 599 { // validating status code
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	imgURL := fmt.Sprintf("http://localhost:8080/api/cat/%d", codeStatus)
	response := models.HTTPStatusResponse{
		StatusCode:  codeStatus,
		ImageURL:    imgURL,
		Description: getHTTPStatusDescription(codeStatus),
	}
	h.writeJSON(w, http.StatusOK, map[string]interface{}{
		"success": true,
		"data":    response,
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
	w.Header().Set("Content-Type", "application/json")
	h.writeJSON(w, http.StatusOK, map[string]string{"status": "healthy"})
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// Avoid writing body for status codes that must not have one
	if status == http.StatusNoContent || status == http.StatusNotModified {
		w.WriteHeader(status)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	// Only call WriteHeader once
	w.WriteHeader(status)

	// Only encode non-nil data
	if data != nil {
		if err := json.NewEncoder(w).Encode(data); err != nil {
			log.Printf("Error encoding JSON: %v", err)
		}
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	// Create APIResponse with Success: false and Error: message
	// Use writeJSON to send the error response
	h.writeJSON(w, status, map[string]interface{}{ // sends a standard error response back to the client in JSON format
		"success": false,
		"error":   message,
	})
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	// Decode into destination interface
	// Return any decoding errors
	decoder := json.NewDecoder(r.Body) // reading JSON data from the HTTP request body
	return decoder.Decode(dst)         // decoding it into Go struct
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
	case 100:
		return "Continue"
	case 101:
		return "Switching Protocols"
	case 200:
		return "OK"
	case 202:
		return "Accepted"
	case 204:
		return "No Content"
	case 301:
		return "Moved Permanently"
	case 302:
		return "Found"
	case 304:
		return "Not Modified"
	case 400:
		return "Bad Request"
	case 401:
		return "Unauthorized"
	case 403:
		return "Forbidden"
	case 404:
		return "Not Found"
	case 422:
		return "Unprocessable Entity"
	case 429:
		return "Too Many Requests"
	case 500:
		return "Internal Server Error"
	case 502:
		return "Bad Gateway"
	case 503:
		return "Service Unavailable"
	case 504:
		return "Gateway Timeout"
	default:
		return "Unknown Status"
	}
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler { // takes the handler and wraps it with CORS logic
	// TODO: Implement CORS middleware
	// Set the following headers:
	// Access-Control-Allow-Origin: *
	// Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
	// Access-Control-Allow-Headers: Content-Type, Authorization
	// Handle OPTIONS preflight requests
	// Call next handler for non-OPTIONS requests
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { //
		// TODO: Implement CORS logic here
		/*
			Set HTTP headers that allow cross-origin requests
		*/
		origin := r.Header.Get("Origin")
		if origin == "http://localhost:3000" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		}
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS") // tells which HTTP methods are allowed from the frontend
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")     // tells which HTTP headers are allowed
		if r.Method == http.MethodOptions {                                               // handles CORS "preflight" requests
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r) // for all other methods, we pass the request to the actual handler
	})
}
