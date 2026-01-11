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
	r := mux.NewRouter()
	r.Use(corsMiddleware)

	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods("GET")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET")
	api.HandleFunc("/cat/{code}", h.ProxyCat).Methods("GET")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")

	return r
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	msgs := h.storage.GetAll()
	h.writeJSON(w, http.StatusOK, &models.APIResponse{
		Success: true,
		Data:    msgs,
	})
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON: "+err.Error())
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}
	h.writeJSON(w, http.StatusCreated, &models.APIResponse{
		Success: true,
		Data:    msg,
	})
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id")
		return
	}

	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON: "+err.Error())
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	updated, err := h.storage.Update(id, req.Content)
	if err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}

	h.writeJSON(w, http.StatusOK, &models.APIResponse{
		Success: true,
		Data:    updated,
	})
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid id")
		return
	}
	if err := h.storage.Delete(id); err != nil {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}

	host := r.Host
	var imageURL string
	if r.TLS != nil {
		imageURL = fmt.Sprintf("https://%s/api/cat/%d", host, code)
	} else {
		imageURL = fmt.Sprintf("http://%s/api/cat/%d", host, code)
	}
	payload := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    imageURL,
		Description: getHTTPStatusDescription(code),
	}

	h.writeJSON(w, http.StatusOK, &models.APIResponse{
		Success: true,
		Data:    payload,
	})
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	resp := struct {
		Status        string    `json:"status"`
		Message       string    `json:"message"`
		Timestamp     time.Time `json:"timestamp"`
		TotalMessages int       `json:"total_messages"`
	}{
		Status:        "healthy",
		Message:       "API is running",
		Timestamp:     time.Now(),
		TotalMessages: h.storage.Count(),
	}
	h.writeJSON(w, http.StatusOK, resp)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("writeJSON: encode error: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	resp := &models.APIResponse{
		Success: false,
		Error:   message,
	}
	h.writeJSON(w, status, resp)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	dec := json.NewDecoder(r.Body)
	return dec.Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	switch code {
	case http.StatusOK:
		return "OK"
	case http.StatusCreated:
		return "Created"
	case http.StatusNoContent:
		return "No Content"
	case http.StatusBadRequest:
		return "Bad Request"
	case http.StatusUnauthorized:
		return "Unauthorized"
	case http.StatusNotFound:
		return "Not Found"
	case http.StatusInternalServerError:
		return "Internal Server Error"
	default:
		return "Unknown Status"
	}
}

func (h *Handler) ProxyCat(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code := vars["code"]
	// fetch the real image
	resp, err := http.Get("https://http.cat/" + code)
	if err != nil {
		http.Error(w, "cannot fetch image", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	// copy headers & status
	for k, v := range resp.Header {
		w.Header()[k] = v
	}
	w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			// Preflight request, no further handling
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
