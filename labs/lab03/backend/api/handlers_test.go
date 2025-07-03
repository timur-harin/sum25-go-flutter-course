package api

import (
	"bytes"
	"encoding/json"
	"lab03-backend/models"
	"lab03-backend/storage"
	"net/http"
	"net/http/httptest"
	"testing"
)

func setupTestHandler() *Handler {
	storage := storage.NewMemoryStorage()
	return NewHandler(storage)
}

func TestGetMessages(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	req, err := http.NewRequest("GET", "/api/messages", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Expected status %v, got %v", http.StatusOK, status)
	}

	var response models.APIResponse
	err = json.NewDecoder(rr.Body).Decode(&response)
	if err != nil {
		t.Fatalf("Could not decode response: %v", err)
	}

	if !response.Success {
		t.Error("Expected success to be true")
	}
}

func TestCreateMessage(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	createReq := models.CreateMessageRequest{
		Username: "testuser",
		Content:  "test message",
	}

	jsonData, _ := json.Marshal(createReq)
	req, err := http.NewRequest("POST", "/api/messages", bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusCreated {
		t.Errorf("Expected status %v, got %v", http.StatusCreated, status)
	}

	var response models.APIResponse
	err = json.NewDecoder(rr.Body).Decode(&response)
	if err != nil {
		t.Fatalf("Could not decode response: %v", err)
	}

	if !response.Success {
		t.Error("Expected success to be true")
	}
}

func TestUpdateMessage(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	// First create a message
	createReq := models.CreateMessageRequest{
		Username: "testuser",
		Content:  "original message",
	}

	jsonData, _ := json.Marshal(createReq)
	createHttpReq, _ := http.NewRequest("POST", "/api/messages", bytes.NewBuffer(jsonData))
	createHttpReq.Header.Set("Content-Type", "application/json")

	createRr := httptest.NewRecorder()
	router.ServeHTTP(createRr, createHttpReq)

	// Now update the message
	updateReq := models.UpdateMessageRequest{
		Content: "updated message",
	}

	jsonData, _ = json.Marshal(updateReq)
	req, err := http.NewRequest("PUT", "/api/messages/1", bytes.NewBuffer(jsonData))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Expected status %v, got %v", http.StatusOK, status)
	}
}

func TestDeleteMessage(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	// First create a message
	createReq := models.CreateMessageRequest{
		Username: "testuser",
		Content:  "message to delete",
	}

	jsonData, _ := json.Marshal(createReq)
	createHttpReq, _ := http.NewRequest("POST", "/api/messages", bytes.NewBuffer(jsonData))
	createHttpReq.Header.Set("Content-Type", "application/json")

	createRr := httptest.NewRecorder()
	router.ServeHTTP(createRr, createHttpReq)

	// Now delete the message
	req, err := http.NewRequest("DELETE", "/api/messages/1", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusNoContent {
		t.Errorf("Expected status %v, got %v", http.StatusNoContent, status)
	}
}

func TestGetHTTPStatus(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	tests := []struct {
		code           string
		expectedStatus int
	}{
		{"200", http.StatusOK},
		{"404", http.StatusOK},
		{"500", http.StatusOK},
		{"999", http.StatusBadRequest}, // Invalid status code
	}

	for _, tt := range tests {
		t.Run("status_"+tt.code, func(t *testing.T) {
			req, err := http.NewRequest("GET", "/api/status/"+tt.code, nil)
			if err != nil {
				t.Fatal(err)
			}

			rr := httptest.NewRecorder()
			router.ServeHTTP(rr, req)

			if status := rr.Code; status != tt.expectedStatus {
				t.Errorf("Expected status %v, got %v", tt.expectedStatus, status)
			}

			if tt.expectedStatus == http.StatusOK {
				var response models.APIResponse
				err = json.NewDecoder(rr.Body).Decode(&response)
				if err != nil {
					t.Fatalf("Could not decode response: %v", err)
				}

				if !response.Success {
					t.Error("Expected success to be true")
				}
			}
		})
	}
}

func TestHealthCheck(t *testing.T) {
	handler := setupTestHandler()
	router := handler.SetupRoutes()

	req, err := http.NewRequest("GET", "/api/health", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	router.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("Expected status %v, got %v", http.StatusOK, status)
	}

	// Should return JSON with health status
	contentType := rr.Header().Get("Content-Type")
	if contentType != "application/json" {
		t.Errorf("Expected Content-Type application/json, got %s", contentType)
	}
}
