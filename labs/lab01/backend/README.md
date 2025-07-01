# Lab 01 - Go Backend

This directory contains the Go implementation of three components:

1. **Calculator Package**: Basic arithmetic operations and type conversions
2. **User Management**: User struct with validation methods
3. **Task Manager**: In-memory task management system

## Getting Started

### Prerequisites
- Go 1.24 or higher

### Running Tests
To run all tests:
```bash
go test ./...
```

To run tests for a specific package:
```bash
go test ./calculator
go test ./user
go test ./taskmanager
```

To run tests with coverage:
```bash
go test -cover ./...
```

## Components

### Calculator Package
- Basic arithmetic operations (add, subtract, multiply, divide)
- Type conversion utilities
- Error handling for division by zero and invalid conversions

### User Management
- User struct with name, age, and email fields
- Validation methods for user data
- Error handling for invalid input

### Task Manager
- Task struct with ID, title, description, and status
- CRUD operations for tasks
- Error handling for invalid operations
- In-memory storage implementation 