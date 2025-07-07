package api

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"

	"lab03-backend/models"
	"lab03-backend/storage"

	"github.com/gorilla/mux"
)

type Handler struct {
	storage *storage.MemoryStorage
}


func NewHandler(storage *storage.MemoryStorage) *Handler {
	return &Handler{storage: storage}
}

func (h *Handler) SetupRoutes() *mux.Router {
	router := mux.NewRouter()
	// CORS middleware
	router.Use(corsMiddleware)

	api := router.PathPrefix("/api").Subrouter()
	api.HandleFunc("/messages", h.GetMessages).Methods("GET", "OPTIONS")
	api.HandleFunc("/messages", h.CreateMessage).Methods("POST", "OPTIONS")
	api.HandleFunc("/messages/{id}", h.UpdateMessage).Methods("PUT", "OPTIONS")
	api.HandleFunc("/messages/{id}", h.DeleteMessage).Methods("DELETE", "OPTIONS")
	api.HandleFunc("/status/{code}", h.GetHTTPStatus).Methods("GET", "OPTIONS")
	api.HandleFunc("/health", h.HealthCheck).Methods("GET", "OPTIONS")
	api.HandleFunc("/cat/{code}", h.ProxyCat).Methods("GET", "OPTIONS")

	return router
}

// GetMessages — GET /api/messages
func (h *Handler) GetMessages(w http.ResponseWriter, r *http.Request) {
	resp := models.APIResponse{
		Success: true,
		Data:    h.storage.GetAll(),
	}
	h.writeJSON(w, http.StatusOK, resp)
}

// CreateMessage — POST /api/messages
func (h *Handler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	var req models.CreateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON body")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Create(req.Username, req.Content)
	if err != nil {
		h.writeError(w, http.StatusInternalServerError, "could not create message")
		return
	}
	h.writeJSON(w, http.StatusCreated, models.APIResponse{Success: true, Data: msg})
}

// UpdateMessage — PUT /api/messages/{id}
func (h *Handler) UpdateMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	var req models.UpdateMessageRequest
	if err := h.parseJSON(r, &req); err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid JSON body")
		return
	}
	if err := req.Validate(); err != nil {
		h.writeError(w, http.StatusBadRequest, err.Error())
		return
	}
	msg, err := h.storage.Update(id, req.Content)
	if err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, "could not update message")
		}
		return
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: msg})
}

// DeleteMessage — DELETE /api/messages/{id}
func (h *Handler) DeleteMessage(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id, err := strconv.Atoi(vars["id"])
	if err != nil {
		h.writeError(w, http.StatusBadRequest, "invalid message ID")
		return
	}
	if err := h.storage.Delete(id); err != nil {
		if err == storage.ErrMessageNotFound {
			h.writeError(w, http.StatusNotFound, err.Error())
		} else {
			h.writeError(w, http.StatusInternalServerError, "could not delete message")
		}
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// GetHTTPStatus — GET /api/status/{code}
func (h *Handler) GetHTTPStatus(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code, err := strconv.Atoi(vars["code"])
	if err != nil || code < 100 || code > 599 {
		h.writeError(w, http.StatusBadRequest, "invalid status code")
		return
	}
	// Формируем локальный URL для проксирования изображения
	scheme := "http"
	if r.TLS != nil {
		scheme = "https"
	}
	base := fmt.Sprintf("%s://%s", scheme, r.Host)
	statusResp := models.HTTPStatusResponse{
		StatusCode:  code,
		ImageURL:    fmt.Sprintf("%s/api/cat/%d", base, code),
		Description: getHTTPStatusDescription(code),
	}
	h.writeJSON(w, http.StatusOK, models.APIResponse{Success: true, Data: statusResp})
}

// HealthCheck — GET /api/health
// Возвращаем упрощённый JSON с полем status="healthy"
func (h *Handler) HealthCheck(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

// ProxyCat — GET /api/cat/{code}, тянет картинку с https://http.cat и проксирует
func (h *Handler) ProxyCat(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	code := vars["code"]
	upstream := fmt.Sprintf("https://http.cat/%s", code)
	resp, err := http.Get(upstream)
	if err != nil {
		http.Error(w, "failed to fetch image", http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	// Копируем все заголовки
	for k, vv := range resp.Header {
		w.Header()[k] = vv
	}
	// Переустанавливаем CORS на нужный origin
	w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
	w.WriteHeader(resp.StatusCode)
	io.Copy(w, resp.Body)
}

// --- вспомогательные методы ---

func (h *Handler) writeJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("writeJSON error: %v", err)
	}
}

func (h *Handler) writeError(w http.ResponseWriter, status int, message string) {
	h.writeJSON(w, status, models.APIResponse{
		Success: false,
		Error:   message,
	})
}

func (h *Handler) parseJSON(r *http.Request, dst interface{}) error {
	return json.NewDecoder(r.Body).Decode(dst)
}

func getHTTPStatusDescription(code int) string {
	switch code {
	case 200:
		return "OK"
	case 201:
		return "Created"
	case 204:
		return "No Content"
	case 400:
		return "Bad Request"
	case 401:
		return "Unauthorized"
	case 403:
		return "Forbidden"
	case 404:
		return "Not Found"
	case 500:
		return "Internal Server Error"
	case 502:
		return "Bad Gateway"
	case 503:
		return "Service Unavailable"
	default:
		return "Unknown Status"
	}
}

// CORS middleware для всех /api маршрутов
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Жёстко разрешаем только ваш фронтенд
		w.Header().Set("Access-Control-Allow-Origin", "http://localhost:3000")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}
