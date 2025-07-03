# Lab 03: REST API Chat System with HTTP Status Codes

## Overview

Build a complete REST API chat system using Go backend and Flutter frontend, with integrated HTTP status code visualization using the HTTP Cat API.

## Learning Objectives

- Implement RESTful endpoints with proper HTTP methods
- Handle different HTTP status codes appropriately  
- Build Flutter HTTP client with error handling
- Integrate external APIs (HTTP Cat status codes)
- Practice full-stack communication patterns

## Project Structure

```
lab03/
├── backend/
│   ├── go.mod
│   ├── api/
│   │   └── handlers.go          # TODO: HTTP handlers
│   ├── models/
│   │   └── message.go           # TODO: Message model  
│   ├── storage/
│   │   └── memory.go            # TODO: In-memory storage
│   └── main.go                  # TODO: Server setup
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   │   └── message.dart     # TODO: Message model
│   │   ├── services/
│   │   │   └── api_service.dart # TODO: HTTP client
│   │   ├── screens/
│   │   │   └── chat_screen.dart # TODO: Chat UI
│   │   └── main.dart            # TODO: App setup
│   └── pubspec.yaml
└── README.md
```

## Task Requirements

### Backend (Go) - REST API Endpoints

Implement the following endpoints:

1. **GET /api/messages** - Retrieve all messages
2. **POST /api/messages** - Create a new message  
3. **PUT /api/messages/{id}** - Update a message
4. **DELETE /api/messages/{id}** - Delete a message
5. **GET /api/status/{code}** - Get HTTP cat image URL for status code
6. **GET /api/health** - Health check endpoint

### Frontend (Flutter) - HTTP Client

Implement the following features:

1. **Message List** - Display messages from API
2. **Add Message** - Send new messages via POST
3. **Edit Message** - Update messages via PUT  
4. **Delete Message** - Remove messages via DELETE
5. **Status Code Display** - Show HTTP cat images for different responses
6. **Error Handling** - Handle network errors gracefully

## Setup Instructions

### Prerequisites

- Go 1.24.3+ installed
- Flutter 3.32.1+ installed
- Internet connection (for HTTP Cat API)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd labs/lab03/backend
   ```

2. Initialize Go module (if not already done):
   ```bash
   go mod init lab03-backend
   ```

3. Install dependencies:
   ```bash
   go mod tidy
   ```

4. Run the server:
   ```bash
   go run main.go
   ```

5. Server should start on `http://localhost:8080`

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd labs/lab03/frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome  # For web
   # or
   flutter run             # For mobile/desktop
   ```

### Testing

Run backend tests:
```bash
cd labs/lab03/backend
go test ./...
```

Run frontend tests:
```bash
cd labs/lab03/frontend
flutter test
```

## API Documentation

### Message Model
```json
{
  "id": 1,
  "username": "john_doe",
  "content": "Hello, World!",
  "timestamp": "2025-07-02T10:00:00Z"
}
```

### Endpoints

#### GET /api/messages
**Response:** `200 OK`
```json
[
  {
    "id": 1,
    "username": "john_doe", 
    "content": "Hello, World!",
    "timestamp": "2025-07-02T10:00:00Z"
  }
]
```

#### POST /api/messages  
**Request Body:**
```json
{
  "username": "jane_doe",
  "content": "New message"
}
```
**Response:** `201 Created`

#### PUT /api/messages/{id}
**Request Body:**
```json
{
  "content": "Updated message content"
}
```
**Response:** `200 OK`

#### DELETE /api/messages/{id}
**Response:** `204 No Content`

#### GET /api/status/{code}
**Response:** `200 OK`
```json
{
  "status_code": 404,
  "image_url": "https://http.cat/404",
  "description": "Not Found"
}
```

## HTTP Status Codes to Handle

- `200 OK` - Successful GET/PUT operations
- `201 Created` - Successful POST operations  
- `204 No Content` - Successful DELETE operations
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Message not found
- `500 Internal Server Error` - Server errors

## Common Issues & Solutions

### Backend Issues

1. **Port already in use**
   ```
   Error: listen tcp :8080: bind: address already in use
   ```
   **Solution:** Change port in `main.go` or kill process using port 8080

2. **CORS errors when accessing from Flutter web**
   ```
   Access to fetch at 'http://localhost:8080' from origin 'http://localhost:3000' 
   has been blocked by CORS policy
   ```
   **Solution:** Ensure CORS middleware is properly configured in Go backend

3. **JSON parsing errors**
   ```
   json: cannot unmarshal string into Go struct field
   ```
   **Solution:** Check JSON tags in Go structs match request/response format

### Frontend Issues

1. **Network errors in Flutter web**
   ```
   SocketException: Failed host lookup
   ```
   **Solution:** Ensure backend is running and accessible from browser

2. **HTTP package not found**
   ```
   Target of URI doesn't exist: 'package:http/http.dart'
   ```
   **Solution:** Add http dependency to `pubspec.yaml` and run `flutter pub get`

3. **CORS issues in web development**
   **Solution:** Run Flutter web with `--web-renderer html` flag:
   ```bash
   flutter run -d chrome --web-renderer html
   ```

4. **State not updating in UI**
   **Solution:** Ensure `setState()` is called after API operations or use proper state management

### Integration Issues

1. **HTTP Cat API not loading images**
   - Check internet connection
   - Verify status codes are valid (100-599)
   - Use fallback images for offline mode

2. **Response format mismatch between Go and Flutter**
   - Ensure JSON field names match exactly
   - Use proper Dart model classes with `fromJson`/`toJson`

3. **Timing issues between requests**
   - Add proper loading states
   - Implement retry mechanisms for failed requests

## Success Criteria

Your lab is complete when all tests pass:

### Backend Tests (3/6)
- ✅ Message CRUD operations work correctly
- ✅ HTTP status code endpoint returns proper data  
- ✅ Error handling returns appropriate status codes

### Frontend Tests (3/6)
- ✅ API service can communicate with backend
- ✅ Chat screen displays and updates messages
- ✅ HTTP status code images display correctly

## Bonus Features (Optional)

- Add message filtering/search functionality
- Implement real-time updates with WebSocket
- Add message reactions/likes
- Implement message persistence with database
- Add user authentication
- Implement message pagination

## Resources

- [Go HTTP Package Documentation](https://pkg.go.dev/net/http)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [HTTP Cat API](https://http.cat/)
- [REST API Design Best Practices](https://restfulapi.net/)
- [Course Lecture 03: Data & APIs](../../slides/lecture03/)

## Submission

1. Complete all TODO items in the code
2. Ensure all tests pass locally
3. Push your changes to a branch named `lab03-<your-name>`
4. Create a pull request with your implementation
5. Automated tests will run and provide feedback

Good luck! 🚀 