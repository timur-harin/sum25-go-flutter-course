# Lab 05: Advanced Patterns

This lab focuses on implementing advanced development patterns including Clean Architecture, JWT authentication, security best practices, and comprehensive testing.

## Learning Objectives

- Apply Clean Architecture principles in Go and Flutter
- Implement JWT authentication with proper security
- Use bcrypt for secure password hashing
- Create comprehensive unit tests
- Implement authentication service with state management
- Apply dependency injection and interface abstractions
- Implement basic form validation and security

## Prerequisites

- Go 1.24+
- Flutter 3.32.1+
- Understanding of basic authentication concepts
- Familiarity with unit testing

## Project Structure

```
lab05/
├── backend/
│   ├── userdomain/          # User domain entities and business logic
│   ├── jwtservice/          # JWT token generation and validation
│   └── security/            # Password hashing and validation
└── frontend/
    ├── lib/
    │   ├── domain/entities/ # Clean architecture entities
    │   ├── core/auth/       # Authentication service
    │   └── core/validation/ # Form validation
    └── test/                # Unit tests
```

## Tasks

### Go Backend Tasks

#### Task 1: User Domain Service (`userdomain` package)
Implement clean architecture domain entities and business logic:

**Files to implement:**
- `userdomain/user.go` - User entity with validation
- `userdomain/repository.go` - Repository interface (clean architecture)
- `userdomain/user_test.go` - Comprehensive unit tests

**Key requirements:**
- User entity with ID, Name, Email, CreatedAt fields
- Email validation (basic format checking)
- Repository interface following dependency inversion principle
- Clean separation of business logic from infrastructure

#### Task 2: JWT Authentication Service (`jwtservice` package)
Implement JWT token generation and validation:

**Files to implement:**
- `jwtservice/jwt.go` - JWT service with token operations
- `jwtservice/claims.go` - JWT claims structure
- `jwtservice/jwt_test.go` - Unit tests for JWT operations

**Key requirements:**
- Generate JWT tokens with user claims (HS256 algorithm)
- Validate JWT tokens and extract claims
- Handle token expiration (24 hours)
- Proper error handling for invalid tokens

#### Task 3: Security Service (`security` package)
Implement password hashing and validation:

**Files to implement:**
- `security/password.go` - Password service with bcrypt
- `security/password_test.go` - Security-focused unit tests

**Key requirements:**
- Hash passwords using bcrypt (cost 10)
- Verify passwords against hashes
- Basic password validation (6+ chars, letter + number)
- Secure password comparison

### Flutter Frontend Tasks

#### Task 1: User Entity & Use Case (`domain/entities`)
Implement clean architecture entities:

**Files to implement:**
- `lib/domain/entities/user.dart` - User entity with Equatable
- `test/user_entity_test.dart` - Entity unit tests

**Key requirements:**
- User entity following clean architecture principles
- Immutable entity with Equatable for value comparison
- Proper toString() and equality implementations

#### Task 2: Authentication Service (`core/auth`)
Implement authentication service with clean architecture:

**Files to implement:**
- `lib/core/auth/auth_service.dart` - Authentication service with state management
- `test/auth_service_test.dart` - Authentication unit tests

**Key requirements:**
- Login/logout functionality with state management
- Email and password validation using FormValidator
- JWT token simulation with proper validation
- Session management with expiry checking
- Comprehensive error handling (validation, credentials, network)
- Clean dependency injection for testing

#### Task 3: Form Validation (`core/validation`)
Implement form validation with basic security:

**Files to implement:**
- `lib/core/validation/form_validator.dart` - Form validation utilities
- `test/form_validator_test.dart` - Validation unit tests

**Key requirements:**
- Email validation (basic format and length)
- Password validation (6+ chars, letter + number)
- Text sanitization (remove < > characters)
- Length validation utilities

## Setup Instructions

### Backend Setup
```bash
cd labs/lab05/backend

# Initialize Go module (if not already done)
go mod init lab05

# Install dependencies
go mod tidy

# Run tests
go test ./...
```

### Frontend Setup
```bash
cd labs/lab05/frontend

# Install dependencies
flutter pub get

# Run tests
flutter test
```

## Implementation Guidelines

### Clean Architecture Principles
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Separation of Concerns**: Each layer has a specific responsibility
- **Testability**: Each component can be tested in isolation

### Security Best Practices
- Use bcrypt for password hashing (never store plain text)
- Validate all inputs (email format, password complexity)
- Implement proper authentication flow with state management
- Sanitize inputs to prevent basic injection attacks
- Use dependency injection for testable security components

### Testing Strategy
- **Unit Tests**: Test individual functions and methods
- **Mocking**: Use interfaces to mock dependencies
- **Coverage**: Aim for good test coverage of business logic
- **Edge Cases**: Test error conditions and boundary cases

## Evaluation Criteria

### Functionality (60%)
- All TODO methods implemented correctly
- Proper error handling and validation
- Security best practices followed

### Testing (25%)
- All unit tests pass
- Good test coverage
- Tests cover both happy path and error cases

### Code Quality (15%)
- Clean, readable code
- Proper separation of concerns
- Following Go and Dart conventions

## Common Pitfalls

1. **Password Security**: Never store passwords in plain text
2. **Authentication State**: Properly manage authentication state and session validity
3. **Input Validation**: Validate all user inputs before processing
4. **Error Handling**: Don't expose sensitive error details
5. **Testing**: Don't forget to test error conditions and dependency injection
6. **Interface Design**: Use proper abstractions for testable components

## Resources

- [Clean Architecture Blog Post](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [JWT.io](https://jwt.io/) - JWT debugging and information
- [bcrypt Package](https://pkg.go.dev/golang.org/x/crypto/bcrypt)
- [Dependency Injection in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

## Help

If you encounter issues:
1. Check the test output for specific error messages
2. Review the TODO comments for implementation hints
3. Ensure all dependencies are installed correctly
4. Verify your implementation follows the specified interfaces

Good luck with implementing advanced patterns! 🚀 