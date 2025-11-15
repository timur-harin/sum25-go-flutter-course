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
	return &Handler{storage: storage}
}

// SetupRoutes configures all API routes
func (h *Handler) SetupRoutes() *mux.Router {
	// Configure router and API routes
	router := mux.NewRouter()
	router.Use(corsMiddleware)

	apiRouter := router.PathPrefix("/api").Subrouter()
	apiRouter.HandleFunc("/messages", h.GetMessages).Methods("GET")
	apiRouter.HandleFunc("/messages", h.CreateMessage).Methods("POST")
	apiRouter.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT")
	apiRouter.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE")
	apiRouter.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET")
	apiRouter.HandleFunc("/cat/{code}", h.GetCatImage).Methods("GET")
	apiRouter.HandleFunc("/health", h.HealthCheck).Methods("GET")
	return router
}

// GetMessages handles GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	messages := h.storage.GetAll()
	resp := models.APIResponse{Success: true, Data: messages}
	h.writeJSON(w, http.StatusOK, resp)
}

// CreateMessage handles POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
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

	resp := models.APIResponse{Success: true, Data: msg}
	h.writeJSON(w, http.StatusCreated, resp)
}

// UpdateMessage handles PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}

	msg, err := h.storage.Update(id, req.Content)
	if err == storage.ErrMessageNotFound {
		h.writeError(w, http.StatusNotFound, err.Error())
		return
	} else if err != nil {
		h.writeError(w, http.StatusInternalServerError, err.Error())
		return
	}

	resp := models.APIResponse{Success: true, Data: msg}
	h.writeJSON(w, http.StatusOK, resp)
}

// DeleteMessage handles DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["id"]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "Invalid message ID")
		return
	}

	if err := h.storage.Delete(id); err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, err.Error())
		}
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus handles GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	codeStr := vars["code"]

	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "Invalid status code")
		return
	}

	statusResp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("http://localhost:8080/api/cat/%d", code),
		Description: getHTTPStatusDescription(code),
	}

	resp := models.APIResponse{Success: true, Data: statusResp}
	h.writeJSON(w, http.StatusOK, resp)
}

// GetCatImage proxies HTTP cat images with proper CORS headers
func (h *Handler) GetCatImage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	codeStr := vars["code"]

	code, err := strconv.Atoi(codeStr)
	if err != nil || code < 100 || code > 599 {
		http.Error(w, "invalid status code", http.StatusBadRequest)
		return
	}

	resp, err := http.Get(fmt.Sprintf("https://http.cat/%d", code))
	if err != nil {
		http.Error(w, "failed to fetch image", http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		http.Error(w, "image not found", resp.StatusCode)
		return
	}

	w.Header().Set("Content-Type", resp.Header.Get("Content-Type"))
	if origin := r.Header.Get("Origin"); origin != "" {
		w.Header().Set("Access-Control-Allow-Origin", origin)
	} else {
		w.Header().Set("Access-Control-Allow-Origin", "*")
	}

	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("failed to write image: %v", err)
	}
}

// HealthCheck handles GET /api/health
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	respData := struct {
		Status    string    `json:"status"`
		Timestamp time.Time `json:"timestamp"`
		Version   string    `json:"version"`
	}{
		Status:    "healthy",
		Timestamp: time.Now(),
		Version:   "1.0.0",
	}

	resp := models.APIResponse{Success: true, Data: respData}
	h.writeJSON(w, http.StatusOK, resp)
}

// Helper function to write JSON responses
func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("failed to encode response: %v", err)
	}
}

// Helper function to write error responses
func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	resp := models.APIResponse{Success: false, Error: message}
	h.writeJSON(w, status, resp)
}

// Helper function to parse JSON request body
func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	dec := json.NewDecoder(r.Body)
	return dec.Decode(dst)
}

// Helper function to get HTTP status description
func getHTTPStatusDescription(code int) string {
	desc := http.StatusText(code)
	if desc == "" {
		return "Unknown Status"
	}
	return desc
}

// CORS middleware
func corsMiddleware(next http.Handler) http.Handler {
	// Allowed origins for CORS
	allowed := map[string]struct{}{
		"http://localhost:3000": {},
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if _, ok := allowed[origin]; ok {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}
