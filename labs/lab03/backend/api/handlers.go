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
	response := models.APIResponse{
		Success: true,
		Data:    &messages,
		Error:   "",
	}
	h.writeJSON(w, 200, response)

}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	h.parseJSON(r, &req)
	err := req.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	message, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
	}
	response := models.APIResponse{
		Success: true,
		Data:    message,
		Error:   "",
	}
	h.writeJSON(w, 201, response)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	ID_ := vars["id"]
	ID, err := strconv.Atoi(ID_)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	var req models.UpdateMessageRequest
	err = h.parseJSON(r, &req)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	err = req.Validate()
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	message, e := h.storage.Update(ID, req.Content)
	if e != nil {
		h.writeError(w, http.StatusInternalServerError, e.Error())
	}
	response := models.APIResponse{
		Success: true,
		Data:    message,
		Error:   "",
	}
	h.writeJSON(w, 200, response)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	ID_ := vars["id"]
	ID, err := strconv.Atoi(ID_)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	err = h.storage.Delete(ID)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
	}
	h.writeJSON(w, 204, nil)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	code_ := mux.Vars(r)["code"]
	code, err := strconv.Atoi(code_)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
	}
	if code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid HTTP status code")
	}
	response := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    "https://http.cat/{code}",
		Description: getHTTPStatusDescription(code),
	}
	APIresponse := models.APIResponse{
		Success: true,
		Data:    response,
		Error:   "",
	}
	h.writeJSON(w, 200, APIresponse)

}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	response := map[string]interface{}{
		"status":         "healthy",
		"message":        "API is running",
		"timestamp":      time.Now(),
		"total_messages": h.storage.Count(),
	}
	h.writeJSON(w, 200, response)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	encoder := json.NewEncoder(w)
	if err := encoder.Encode(data); err != nil {
		log.Println(err)
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
	if err := decoder.Decode(dst); err != nil {
		return err
	}
	return nil
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	switch code {
	case 100:
		return "Continue"
	case 101:
		return "Switching Protocols"
	case 200:
		return "OK"
	case 201:
		return "Created"
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
	}
	return "Unknown Status"
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// TODO: Implement CORS logic here
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
