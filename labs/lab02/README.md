# Lab 02: Real-time Chat Application

This lab focuses on building a real-time chat application using Go (backend) and Flutter (frontend), based on the concurrency and streams concepts from Lecture 02.

## Tasks Overview

### Go Backend Tasks (3)
1. **Concurrent Message Broker**
   - Implement a chat message broker using goroutines and channels (fan-in/fan-out pattern).
   - Handle multiple users, broadcast, and private messages.
   - Use context for cancellation and timeouts.
2. **User Management with Context**
   - User struct with validation (name, email).
   - Add/remove users, context for request-scoped values.
3. **Message Storage & Synchronization**
   - Store messages in memory, sync with mutex.
   - Retrieve chat history, handle concurrent writes.

### Flutter Frontend Tasks (3)
4. **Chat Service (Streams & Futures)**
   - Dart service for connecting to backend (simulate with mock).
   - Use Streams for real-time messages, Futures for sending.
5. **Chat Screen (StreamBuilder)**
   - UI for chat using `StreamBuilder`.
   - Display messages, input for sending, show loading/error states.
6. **User Profile & Async State**
   - User profile widget, async load/update user info.
   - Use `FutureBuilder`, handle errors, update state.

## Getting Started

### Backend Setup
```bash
cd backend
go mod init lab02
go mod tidy
```

### Frontend Setup
```bash
cd frontend
flutter create .
flutter pub get
```

## Testing

### Backend Tests
```bash
cd backend
go test ./...
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## Evaluation

Each task is worth 1 point. The GitHub Actions workflow will automatically calculate your score based on passing tests.

### Scoring
- Go Backend Tasks: 3 points (1 point each)
- Flutter Frontend Tasks: 3 points (1 point each)
- Total: 6 points

## Submission

Follow the contribution guidelines in the root README.md:
1. Create a branch: `lab02-surname-name`
2. Implement the tasks
3. Ensure all tests pass
4. Create a merge request using CONTRIBUTING.md

## Resources
- [Go Concurrency Patterns](https://talks.golang.org/2012/concurrency.slide)
- [Flutter Async Programming](https://dart.dev/guides/language/language-tour#asynchrony)
- Lecture 02 Slides 