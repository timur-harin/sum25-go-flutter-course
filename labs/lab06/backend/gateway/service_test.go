package gateway

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	pb "lab06-backend/proto"

	"github.com/gorilla/mux"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// MockCalculatorClient implements the Calculator client interface for testing
type MockCalculatorClient struct {
	addResponse      *pb.OperationResponse
	subtractResponse *pb.OperationResponse
	multiplyResponse *pb.OperationResponse
	divideResponse   *pb.OperationResponse
	historyResponse  *pb.HistoryResponse
	shouldError      bool
}

func (m *MockCalculatorClient) Add(ctx context.Context, req *pb.OperationRequest, opts ...grpc.CallOption) (*pb.OperationResponse, error) {
	if m.shouldError {
		return nil, status.Error(codes.Internal, "mock error")
	}
	if m.addResponse != nil {
		return m.addResponse, nil
	}
	return &pb.OperationResponse{
		Result:    req.A + req.B,
		Operation: "add",
		Success:   true,
	}, nil
}

func (m *MockCalculatorClient) Subtract(ctx context.Context, req *pb.OperationRequest, opts ...grpc.CallOption) (*pb.OperationResponse, error) {
	if m.shouldError {
		return nil, status.Error(codes.Internal, "mock error")
	}
	if m.subtractResponse != nil {
		return m.subtractResponse, nil
	}
	return &pb.OperationResponse{
		Result:    req.A - req.B,
		Operation: "subtract",
		Success:   true,
	}, nil
}

func (m *MockCalculatorClient) Multiply(ctx context.Context, req *pb.OperationRequest, opts ...grpc.CallOption) (*pb.OperationResponse, error) {
	if m.shouldError {
		return nil, status.Error(codes.Internal, "mock error")
	}
	if m.multiplyResponse != nil {
		return m.multiplyResponse, nil
	}
	return &pb.OperationResponse{
		Result:    req.A * req.B,
		Operation: "multiply",
		Success:   true,
	}, nil
}

func (m *MockCalculatorClient) Divide(ctx context.Context, req *pb.OperationRequest, opts ...grpc.CallOption) (*pb.OperationResponse, error) {
	if m.shouldError {
		return nil, status.Error(codes.Internal, "mock error")
	}
	if m.divideResponse != nil {
		return m.divideResponse, nil
	}
	if req.B == 0 {
		return nil, status.Error(codes.InvalidArgument, "division by zero")
	}
	return &pb.OperationResponse{
		Result:    req.A / req.B,
		Operation: "divide",
		Success:   true,
	}, nil
}

func (m *MockCalculatorClient) GetHistory(ctx context.Context, req *pb.HistoryRequest, opts ...grpc.CallOption) (*pb.HistoryResponse, error) {
	if m.shouldError {
		return nil, status.Error(codes.Internal, "mock error")
	}
	if m.historyResponse != nil {
		return m.historyResponse, nil
	}
	return &pb.HistoryResponse{
		Entries: []*pb.HistoryEntry{
			{Operation: "add", A: 1.0, B: 2.0, Result: 3.0, Timestamp: 1234567890},
		},
	}, nil
}

func createTestService() *Service {
	s := &Service{
		calculatorClient: &MockCalculatorClient{},
		router:           mux.NewRouter(),
	}
	s.setupRoutes()
	return s
}

func createTestRouter() *mux.Router {
	s := &Service{
		calculatorClient: &MockCalculatorClient{},
		router:           mux.NewRouter(),
	}
	s.setupRoutes()
	return s.router
}

func TestService_HandleAdd(t *testing.T) {
	service := createTestService()

	reqBody := OperationRequest{A: 5.0, B: 3.0}
	jsonBody, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/v1/calculate/add", bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rr.Code)
	}

	var resp OperationResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("Failed to decode response: %v", err)
	}

	if resp.Result != 8.0 {
		t.Errorf("Expected result 8.0, got %f", resp.Result)
	}

	if resp.Operation != "add" {
		t.Errorf("Expected operation 'add', got '%s'", resp.Operation)
	}

	if !resp.Success {
		t.Error("Expected success to be true")
	}
}

func TestService_HandleSubtract(t *testing.T) {
	service := createTestService()

	reqBody := OperationRequest{A: 10.0, B: 4.0}
	jsonBody, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/v1/calculate/subtract", bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rr.Code)
	}

	var resp OperationResponse
	json.NewDecoder(rr.Body).Decode(&resp)

	if resp.Result != 6.0 {
		t.Errorf("Expected result 6.0, got %f", resp.Result)
	}
}

func TestService_HandleDivideByZero(t *testing.T) {
	service := createTestService()

	reqBody := OperationRequest{A: 10.0, B: 0.0}
	jsonBody, _ := json.Marshal(reqBody)

	req := httptest.NewRequest("POST", "/api/v1/calculate/divide", bytes.NewBuffer(jsonBody))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("Expected status 400, got %d", rr.Code)
	}

	var resp OperationResponse
	json.NewDecoder(rr.Body).Decode(&resp)

	if resp.Success {
		t.Error("Expected success to be false for division by zero")
	}

	if resp.Error != "division by zero" {
		t.Errorf("Expected error 'division by zero', got '%s'", resp.Error)
	}
}

func TestService_HandleHistory(t *testing.T) {
	service := createTestService()

	req := httptest.NewRequest("GET", "/api/v1/history?limit=5", nil)
	rr := httptest.NewRecorder()

	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rr.Code)
	}

	var resp HistoryResponse
	if err := json.NewDecoder(rr.Body).Decode(&resp); err != nil {
		t.Fatalf("Failed to decode response: %v", err)
	}

	if len(resp.Entries) != 1 {
		t.Errorf("Expected 1 history entry, got %d", len(resp.Entries))
	}

	if resp.Entries[0].Operation != "add" {
		t.Errorf("Expected operation 'add', got '%s'", resp.Entries[0].Operation)
	}
}

func TestService_HandleHealth(t *testing.T) {
	service := createTestService()

	req := httptest.NewRequest("GET", "/api/v1/health", nil)
	rr := httptest.NewRecorder()

	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusOK {
		t.Errorf("Expected status 200, got %d", rr.Code)
	}

	var resp map[string]interface{}
	json.NewDecoder(rr.Body).Decode(&resp)

	if resp["status"] != "healthy" {
		t.Errorf("Expected status 'healthy', got '%v'", resp["status"])
	}

	if resp["service"] != "calculator-gateway" {
		t.Errorf("Expected service 'calculator-gateway', got '%v'", resp["service"])
	}
}

func TestService_InvalidRequestBody(t *testing.T) {
	service := createTestService()

	req := httptest.NewRequest("POST", "/api/v1/calculate/add", bytes.NewBuffer([]byte("invalid json")))
	req.Header.Set("Content-Type", "application/json")

	rr := httptest.NewRecorder()
	service.GetRouter().ServeHTTP(rr, req)

	if rr.Code != http.StatusBadRequest {
		t.Errorf("Expected status 400, got %d", rr.Code)
	}
}
