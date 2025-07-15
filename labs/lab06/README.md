# Lab 06: gRPC Microservices & WebSocket Communication

## Learning Objectives
In this lab, you will implement a complete microservices architecture with gRPC communication and real-time WebSocket messaging, demonstrating the concepts from Lecture 06.

## Architecture Overview
```
Frontend (Flutter) 
    ↓ HTTP
Gateway Service (Go) 
    ↓ gRPC  
Calculator Service (Go)
    
Frontend (Flutter)
    ↓ WebSocket
WebSocket Service (Go)
```

## Backend Tasks (Go)

### 1. Protocol Buffers Definition
- **File**: `proto/calculator.proto`
- **Task**: Define calculator service with basic operations
- **Requirements**: Add, Subtract, Multiply, Divide operations with proper message types

### 2. Gateway Service
- **File**: `gateway/service.go` 
- **Task**: HTTP REST API that forwards requests to Calculator gRPC service
- **Requirements**: Handle JSON requests/responses, gRPC client integration

### 3. Calculator gRPC Service
- **File**: `calculator/service.go`
- **Task**: Implement calculator gRPC server
- **Requirements**: All calculator operations, error handling for division by zero

### 4. WebSocket Service  
- **File**: `websocket/service.go`
- **Task**: Real-time messaging with broadcast capabilities
- **Requirements**: Connection management, message broadcasting, heartbeat

## Frontend Tasks (Flutter)

### 1. WebSocket Real-time Chat
- **File**: `lib/screens/websocket_screen.dart`
- **Task**: Real-time messaging interface with time delays
- **Requirements**: Connect/disconnect, send messages, display with timestamps

### 2. Calculator HTTP Interface
- **File**: `lib/screens/calculator_screen.dart` 
- **Task**: Calculator UI that calls backend HTTP API
- **Requirements**: Basic calculator operations, error handling, result display

### 3. Service Status Monitor
- **File**: `lib/screens/status_screen.dart`
- **Task**: Monitor microservices health and performance
- **Requirements**: Service status indicators, response times, connection status

## Generated Code Instructions

### Protocol Buffers Generation
```bash
# Install protoc compiler and Go plugins
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate Go code from proto file (REQUIRED - generates both protobuf and gRPC code)
cd labs/lab06/backend
protoc --go_out=. --go-grpc_out=. proto/calculator.proto

# Alternative simple command (generates protobuf only, you'll need gRPC separately)
# protoc --go_out=. proto/calculator.proto
```

### Important Notes
- The protobuf generation creates two files: `calculator.pb.go` and `calculator_grpc.pb.go`
- Both files are required for the gRPC service to work
- The import `pb "lab06-backend/proto"` is correct for the module structure
- Generated types include: `CalculatorClient`, `CalculatorServer`, `RegisterCalculatorServer`

## Troubleshooting

### Common Issues
1. **Undefined `pb.CalculatorClient`**: Run the protoc command to generate gRPC code
2. **Undefined `pb.RegisterCalculatorServer`**: Ensure both `--go_out` and `--go-grpc_out` are used
3. **Import errors**: Verify `go.mod` module name matches import paths
4. **Go version mismatch**: Ensure Go compiler and tools are the same version

### Validation
```bash
# Check if protobuf files are generated
ls proto/calculator*.go

# Verify compilation
go build ./...

# Run tests
go test ./...
```

## Testing Strategy
- **Unit tests**: Individual service logic
- **Integration tests**: gRPC communication between services  
- **Network simulation**: Mock network delays and failures
- **UI tests**: Flutter widget testing with mocked services

## Expected File Structure
```
lab06/
├── backend/
│   ├── proto/
│   │   └── calculator.proto
│   ├── gateway/
│   │   ├── service.go
│   │   └── service_test.go
│   ├── calculator/
│   │   ├── service.go
│   │   └── service_test.go
│   ├── websocket/
│   │   ├── service.go
│   │   └── service_test.go
│   ├── main.go
│   └── go.mod
└── frontend/
    ├── lib/
    │   ├── screens/
    │   │   ├── websocket_screen.dart
    │   │   ├── calculator_screen.dart
    │   │   └── status_screen.dart
    │   └── services/
    │       ├── websocket_service.dart
    │       └── api_service.dart
    ├── test/
    │   ├── websocket_screen_test.dart
    │   ├── calculator_screen_test.dart
    │   └── status_screen_test.dart
    ├── web/
    └── pubspec.yaml
```

## Scoring Criteria
- **Backend (3 points)**: Gateway service, Calculator gRPC, WebSocket service
- **Frontend (3 points)**: WebSocket UI, Calculator UI, Status monitor
- **Total**: 6 points

## Learning Outcomes
After completing this lab, you will understand:
- gRPC service implementation and client integration
- Microservices communication patterns
- Real-time WebSocket messaging
- Protocol Buffers code generation
- Cross-platform service integration 