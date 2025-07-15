package calculator

import (
	"context"
	"sync"
	"time"

	pb "lab06-backend/proto"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Service implements the Calculator gRPC service
type Service struct {
	pb.UnimplementedCalculatorServer
	history []pb.HistoryEntry
	mutex   sync.RWMutex
}

// NewService creates a new calculator service
func NewService() *Service {
	return &Service{
		history: make([]pb.HistoryEntry, 0),
	}
}

// Add performs addition operation
func (s *Service) Add(ctx context.Context, req *pb.OperationRequest) (*pb.OperationResponse, error) {
	result := req.A + req.B

	s.addToHistory("add", req.A, req.B, result)

	return &pb.OperationResponse{
		Result:    result,
		Operation: "add",
		Success:   true,
	}, nil
}

// Subtract performs subtraction operation
func (s *Service) Subtract(ctx context.Context, req *pb.OperationRequest) (*pb.OperationResponse, error) {
	result := req.A - req.B

	s.addToHistory("subtract", req.A, req.B, result)

	return &pb.OperationResponse{
		Result:    result,
		Operation: "subtract",
		Success:   true,
	}, nil
}

// Multiply performs multiplication operation
func (s *Service) Multiply(ctx context.Context, req *pb.OperationRequest) (*pb.OperationResponse, error) {
	result := req.A * req.B

	s.addToHistory("multiply", req.A, req.B, result)

	return &pb.OperationResponse{
		Result:    result,
		Operation: "multiply",
		Success:   true,
	}, nil
}

// Divide performs division operation with zero check
func (s *Service) Divide(ctx context.Context, req *pb.OperationRequest) (*pb.OperationResponse, error) {
	if req.B == 0 {
		return &pb.OperationResponse{
			Result:    0,
			Operation: "divide",
			Success:   false,
			Error:     "division by zero",
		}, status.Errorf(codes.InvalidArgument, "cannot divide by zero")
	}

	result := req.A / req.B

	s.addToHistory("divide", req.A, req.B, result)

	return &pb.OperationResponse{
		Result:    result,
		Operation: "divide",
		Success:   true,
	}, nil
}

// GetHistory returns operation history
func (s *Service) GetHistory(ctx context.Context, req *pb.HistoryRequest) (*pb.HistoryResponse, error) {
	s.mutex.RLock()
	defer s.mutex.RUnlock()

	limit := int(req.Limit)
	if limit <= 0 || limit > len(s.history) {
		limit = len(s.history)
	}

	// Get the last 'limit' entries
	startIndex := len(s.history) - limit
	entries := make([]*pb.HistoryEntry, limit)

	for i, entry := range s.history[startIndex:] {
		entries[i] = &pb.HistoryEntry{
			Operation: entry.Operation,
			A:         entry.A,
			B:         entry.B,
			Result:    entry.Result,
			Timestamp: entry.Timestamp,
		}
	}

	return &pb.HistoryResponse{
		Entries: entries,
	}, nil
}

// addToHistory adds an operation to the history
func (s *Service) addToHistory(operation string, a, b, result float64) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	entry := pb.HistoryEntry{
		Operation: operation,
		A:         a,
		B:         b,
		Result:    result,
		Timestamp: time.Now().Unix(),
	}

	s.history = append(s.history, entry)

	// Keep only last 100 entries
	if len(s.history) > 100 {
		s.history = s.history[1:]
	}
}
