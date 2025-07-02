# Lab 02 - Go Backend: Real-time Chat

This backend implements the core logic for a real-time chat application using Go concurrency and synchronization primitives.

## Tasks

### 1. Concurrent Message Broker
- Implement a message broker using goroutines and channels (fan-in/fan-out).
- Support multiple users, broadcast, and private messages.
- Use context for cancellation/timeouts.
- **Test:** Simulate concurrent users, check message delivery, test cancellation.

### 2. User Management with Context
- User struct with validation (name, email).
- Add/remove users, context for request-scoped values.
- **Test:** Add/remove/validate users, test context cancellation.

### 3. Message Storage & Synchronization
- Store messages in memory, sync with mutex.
- Retrieve chat history, handle concurrent writes.
- **Test:** Concurrent message storage, retrieval, race condition checks.

## Getting Started

```bash
cd backend
go mod tidy
go test ./...
```

## Concepts Used
- Goroutines, channels, select
- Context for cancellation
- Mutex for synchronization
- Fan-in/fan-out patterns

## Project Structure
```
backend/
├── chatcore/         # Message broker logic
├── user/             # User management
├── message/          # Message storage
├── go.mod
└── README.md
``` 