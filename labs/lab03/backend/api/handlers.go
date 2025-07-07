package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"lab03-backend/models"
	"lab03-backend/storage"

	"github.com/gorilla/mux"
)

// Handler holds the storage instance
type Handler struct {
	storage *storage.MemoryStorage
}

// NewHandler creates a new handler instance
func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage: storage}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	mux := mux.NewRouter()

	mux.Use(corsMiddleware)

	api := mux.PathPrefix("/api").Subrouter()

	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")

	return mux
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()

	// fmt.Println(messages)

	response := struct {
		Success bool              `json:"success"`
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
		Data:    *messageFull,
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

	id, err := strconv.Atoi(vars["id"])
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

	code, err := strconv.Atoi(vars["code"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}

	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "some error")
	}

	response := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("https://http.cat/%d", code),
		Description: http.StatusText(code),
	}

	apiResponse := models.APIResponse{
		Success: true,
		Data:    response,
	}

	h.writeJSON(w, http.StatusOK, apiResponse)
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
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	encoder := json.NewEncoder(w)
	err := encoder.Encode(data)

	if err != nil {
		fmt.Print("Error occurred: ", err.Error())
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, message)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	reader, err := r.GetBody()
	if err != nil {
		return err
	}
	decoder := json.NewDecoder(reader)

	return decoder.Decode(dst)
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
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
