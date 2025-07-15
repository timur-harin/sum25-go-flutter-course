package calculator

import (
	"context"
	"testing"

	pb "lab06-backend/proto"
)

func TestService_Add(t *testing.T) {
	service := NewService()

	req := &pb.OperationRequest{A: 5.0, B: 3.0}
	resp, err := service.Add(context.Background(), req)

	if err != nil {
		t.Fatalf("Add failed: %v", err)
	}

	if resp.Result != 8.0 {
		t.Errorf("Expected 8.0, got %f", resp.Result)
	}

	if resp.Operation != "add" {
		t.Errorf("Expected operation 'add', got '%s'", resp.Operation)
	}

	if !resp.Success {
		t.Error("Expected success to be true")
	}
}

func TestService_Subtract(t *testing.T) {
	service := NewService()

	req := &pb.OperationRequest{A: 10.0, B: 4.0}
	resp, err := service.Subtract(context.Background(), req)

	if err != nil {
		t.Fatalf("Subtract failed: %v", err)
	}

	if resp.Result != 6.0 {
		t.Errorf("Expected 6.0, got %f", resp.Result)
	}

	if resp.Operation != "subtract" {
		t.Errorf("Expected operation 'subtract', got '%s'", resp.Operation)
	}
}

func TestService_Multiply(t *testing.T) {
	service := NewService()

	req := &pb.OperationRequest{A: 7.0, B: 8.0}
	resp, err := service.Multiply(context.Background(), req)

	if err != nil {
		t.Fatalf("Multiply failed: %v", err)
	}

	if resp.Result != 56.0 {
		t.Errorf("Expected 56.0, got %f", resp.Result)
	}

	if resp.Operation != "multiply" {
		t.Errorf("Expected operation 'multiply', got '%s'", resp.Operation)
	}
}

func TestService_Divide(t *testing.T) {
	service := NewService()

	req := &pb.OperationRequest{A: 15.0, B: 3.0}
	resp, err := service.Divide(context.Background(), req)

	if err != nil {
		t.Fatalf("Divide failed: %v", err)
	}

	if resp.Result != 5.0 {
		t.Errorf("Expected 5.0, got %f", resp.Result)
	}

	if resp.Operation != "divide" {
		t.Errorf("Expected operation 'divide', got '%s'", resp.Operation)
	}
}

func TestService_DivideByZero(t *testing.T) {
	service := NewService()

	req := &pb.OperationRequest{A: 10.0, B: 0.0}
	resp, err := service.Divide(context.Background(), req)

	if err == nil {
		t.Error("Expected error for division by zero")
	}

	if resp.Success {
		t.Error("Expected success to be false for division by zero")
	}

	if resp.Error != "division by zero" {
		t.Errorf("Expected error message 'division by zero', got '%s'", resp.Error)
	}
}

func TestService_GetHistory(t *testing.T) {
	service := NewService()

	// Perform some operations
	service.Add(context.Background(), &pb.OperationRequest{A: 1.0, B: 2.0})
	service.Multiply(context.Background(), &pb.OperationRequest{A: 3.0, B: 4.0})

	// Get history
	req := &pb.HistoryRequest{Limit: 10}
	resp, err := service.GetHistory(context.Background(), req)

	if err != nil {
		t.Fatalf("GetHistory failed: %v", err)
	}

	if len(resp.Entries) != 2 {
		t.Errorf("Expected 2 history entries, got %d", len(resp.Entries))
	}

	// Check first operation
	if resp.Entries[0].Operation != "add" {
		t.Errorf("Expected first operation 'add', got '%s'", resp.Entries[0].Operation)
	}

	if resp.Entries[0].Result != 3.0 {
		t.Errorf("Expected first result 3.0, got %f", resp.Entries[0].Result)
	}

	// Check second operation
	if resp.Entries[1].Operation != "multiply" {
		t.Errorf("Expected second operation 'multiply', got '%s'", resp.Entries[1].Operation)
	}

	if resp.Entries[1].Result != 12.0 {
		t.Errorf("Expected second result 12.0, got %f", resp.Entries[1].Result)
	}
}

func TestService_GetHistoryWithLimit(t *testing.T) {
	service := NewService()

	// Perform multiple operations
	for i := 0; i < 5; i++ {
		service.Add(context.Background(), &pb.OperationRequest{A: float64(i), B: 1.0})
	}

	// Get limited history
	req := &pb.HistoryRequest{Limit: 3}
	resp, err := service.GetHistory(context.Background(), req)

	if err != nil {
		t.Fatalf("GetHistory failed: %v", err)
	}

	if len(resp.Entries) != 3 {
		t.Errorf("Expected 3 history entries, got %d", len(resp.Entries))
	}
}
