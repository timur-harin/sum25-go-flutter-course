package api

import (
	// "bufio"
	"encoding/json"
	"fmt"
	"lab03-backend/models"
	"lab03-backend/storage"
	"net/http"
	"strconv"
	"time"

	// "structs"
	
	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		storage: storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	mux := mux.NewRouter()

	mux.Use(corsMiddleware)

	apiv1 := mux.PathPrefix("/api").Subrouter()

	apiv1.HandleFunc("/messages", h.GetMessages).Methods("GET")
	apiv1.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	apiv1.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	apiv1.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	apiv1.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	apiv1.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return mux
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetMessages handler
	messages := h.storage.GetAll()

	fmt.Println(messages)

	response := struct {
		Success bool `json:"success"`
		Data    []*models.Message `json:"data"`
	}{true, messages}

	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var message models.CreateMessageRequest
	if err := h.parseJSON(r, &message); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	if err := message.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	messageFull, err := h.storage.Create(message.Username, message.Content)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	response := models.APIResponse{
		Success: true, 
		Data: *messageFull,
	}

	h.writeJSON(w, 201, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid ID")
		return
	}

	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	updated, err := h.storage.Update(id, req.Content)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	response := struct {
		Success bool
		Data    *models.Message
	}{
		Success: true,
		Data:    updated,
	}
	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid ID")
		return
	}

	err = h.storage.Delete(id)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement GetHTTPStatus handler
	vars := mux.Vars(r)
	code := vars["code"]

	codeInt, err := strconv.Atoi(code)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	if codeInt < 100 || codeInt > 599 {
		h.writeError(w, http.StatusBadRequest, "some error")
	}

	response := models.HTTPStatusResponse{
		StatusCode:  codeInt,
		ImageURL:    fmt.Sprintf("https://http.cat/%d", codeInt),
		Description: http.StatusText(codeInt),
	}

	apiResponse := models.APIResponse{
		Success: true,
		Data: response,
	}

	h.writeJSON(w, 200, apiResponse)

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
	response := struct {
		Status        string `json:"status"`
		Message       string `json:"message"`
		Timestamp     string `json:"timestamp"`
		TotalMessages int    `json:"total_messages"`
	}{
		Status:        "ok",
		Message:       "API is running",
		Timestamp:     time.Now().Format(time.RFC3339),
		TotalMessages: h.storage.Count(),
	}

	h.writeJSON(w, http.StatusOK, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	// TODO: Implement writeJSON helper
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	encoder := json.NewEncoder(w)
	err := encoder.Encode(data)

	if err != nil {
		fmt.Print("Error occured: ", err.Error())
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	// TODO: Implement writeError helper
	h.writeJSON(w, status, message)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	// TODO: Implement parseJSON helper
	// Create JSON decoder from request body
	reader, err := r.GetBody()
	if err != nil {
		return err
	}
	decoder := json.NewDecoder(reader)

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
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
