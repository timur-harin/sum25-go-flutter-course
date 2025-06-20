# Lab 01: Foundations

This lab focuses on implementing basic Go and Flutter components based on the fundamental concepts covered in Lecture 01.

## Tasks Overview

### Go Backend Tasks (3)
1. **Basic Types and Functions**: Implement a calculator package with basic arithmetic operations and type conversions
   - Functions for add, subtract, multiply, divide
   - Type conversion between int, float64, string
   - Error handling for division by zero and invalid conversions

2. **Structs and Methods**: Create a user management system
   - User struct with name, age, email
   - Methods for validation and string representation
   - Error handling for invalid data

3. **Collections and Error Handling**: Implement a simple in-memory task manager
   - Add, remove, update tasks
   - List tasks with filters
   - Proper error handling and validation

### Flutter Frontend Tasks (3)
1. **Basic Widgets**: Create a profile card widget
   - Display user information
   - Proper layout and styling
   - Responsive design

2. **Stateful Widgets**: Implement a counter application
   - Increment/decrement buttons
   - Reset functionality
   - Display current count

3. **Forms and Validation**: Build a user registration form
   - Input fields for name, email, password
   - Form validation
   - Success/error messages

## Getting Started

### Backend Setup
```bash
cd backend
go mod init lab01
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
1. Create a branch: `lab01-surname-name`
2. Implement the tasks
3. Ensure all tests pass
4. Create a merge request using CONTRIBUTING.md

## Resources
- [Go Documentation](https://golang.org/doc/)
- [Flutter Documentation](https://flutter.dev/docs)
- Lecture 01 Slides





