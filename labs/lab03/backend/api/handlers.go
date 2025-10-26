package api

import (
	"encoding/json"
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
	memoryStorage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{
		memoryStorage: storage,
	}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()

	api := router.PathPrefix("/api").Subrouter()

	api.Handle("/messages", corsMiddleware(http.HandlerFunc(h.GetMessages))).Methods("GET")
	api.Handle("/messages", corsMiddleware(http.HandlerFunc(h.CreateMessage))).Methods("POST")
	api.Handle("/messages/{id}", corsMiddleware(http.HandlerFunc(h.UpdateMessage))).Methods("PUT")
	api.Handle("/messages/{id}", corsMiddleware(http.HandlerFunc(h.DeleteMessage))).Methods("DELETE")
	api.Handle("/status/{code}", corsMiddleware(http.HandlerFunc(h.GetHTTPStatus))).Methods("GET")
	api.Handle("/health", corsMiddleware(http.HandlerFunc(h.HealthCheck))).Methods("GET")

	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) != 3 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}

	allMessages := h.memoryStorage.GetAll()

	response := models.APIResponse{
		Success: true,
		Data:    allMessages,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req models.CreateMessageRequest

	parseErr := h.parseJSON(r, &req)
	if parseErr != nil {
		h.writeError(w, http.StatusBadRequest, "Error parsing JSON")
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid data: "+err.Error())
		return
	}

	msg, err := h.memoryStorage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Error creating a message: "+err.Error())
		return
	}

	response := models.APIResponse{
		Success: true,
		Data:    msg,
	}

	h.writeJSON(w, http.StatusCreated, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		h.writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) != 4 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}

	var req models.UpdateMessageRequest

	parseErr := h.parseJSON(r, &req)
	if parseErr != nil {
		h.writeError(w, http.StatusBadRequest, "Error parsing JSON")
		return
	}

	id, err := strconv.Atoi(parts[3])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid data: "+err.Error())
		return
	}

	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid data: "+err.Error())
		return
	}

	msg, err := h.memoryStorage.Update(int(id), req.Content)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Error updating a message: "+err.Error())
		return
	}

	response := models.APIResponse{
		Success: true,
		Data:    msg,
	}

	h.writeJSON(w, http.StatusOK, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		h.writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) != 4 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}

	id, err := strconv.Atoi(parts[3])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid data: "+err.Error())
		return
	}

	deleteErr := h.memoryStorage.Delete(int(id))
	if deleteErr != nil {
		h.writeError(w, http.StatusBadRequest, "Error deleting a message: "+err.Error())
		return
	}

	response := models.APIResponse{
		Success: true,
	}

	h.writeJSON(w, http.StatusNoContent, response)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		h.writeError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}

	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) != 4 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}

	st, err := strconv.Atoi(parts[3])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid data: "+err.Error())
		return
	}

	statusCode := int(st)
	if !(100 <= statusCode && statusCode <= 599) {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	statResponse := models.HTTPStatusResponse{
		StatusCode:  statusCode,
		ImageURL:    "https://http.cat/" + strconv.Itoa(statusCode),
		Description: getHTTPStatusDescription(statusCode),
	}

	apiResponse := models.APIResponse{
		Success: true,
		Data:    statResponse,
	}

	h.writeJSON(w, http.StatusOK, apiResponse)
}

type HealthCheckResponse struct {
	Status         string
	Message        string
	Timestamp      time.Time
	Total_messages int
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	path := r.URL.Path
	parts := strings.Split(path, "/")
	if len(parts) != 3 {
		h.writeError(w, http.StatusBadRequest, "Invalid path")
		return
	}

	healthResponse := HealthCheckResponse{
		Status:         "ok",
		Message:        "API is running",
		Timestamp:      time.Now(),
		Total_messages: h.memoryStorage.Count(),
	}

	h.writeJSON(w, http.StatusOK, healthResponse)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-type", "application/json")
	w.WriteHeader(status)

	encoder := json.NewEncoder(w)
	if err := encoder.Encode(data); err != nil {
		log.Printf("Error encoding response: %v", err)

		http.Error(w, getHTTPStatusDescription(500), 500)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	response := models.APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, response)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&dst)
	defer r.Body.Close()
	return err
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	descriptions := map[int]string{200: "OK", 201: "Created", 204: "No Content",
		400: "Bad Request", 401: "Unauthorized", 404: "Not Found",
		500: "Internal Server Error"}

	msg, exists := descriptions[code]
	if !exists {
		return "Unknown Status"
	}
	return msg
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Controll-Allow-Origin", "*")
		w.Header().Set("Access-Controll-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Controll-Allow-Methods", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
