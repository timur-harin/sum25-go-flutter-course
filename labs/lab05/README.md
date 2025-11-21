# Lab 05: JWT, Security, User Domain (Go + Flutter)

## Project Structure

- `backend/` — Go backend:
  - `jwtservice/` — JWT token operations (creation, validation)
  - `security/` — password services (hashing, verification)
  - `userdomain/` — user business logic (validation, creation, update)
- `frontend/` — Flutter frontend:
  - `lib/` — main application code
  - `test/` — tests for form validation, entities, and services

## How to Run Tests

### Backend (Go)
```sh
cd backend
# Run all tests
go test ./...
```

### Frontend (Flutter)
```sh
cd frontend
# Run all tests
flutter test
```

## Features
- All code is thoroughly commented (GoDoc/Dartdoc) for educational purposes and quick understanding.
- Test coverage includes both business logic and utility functions.
- Example implementations of JWT, secure password handling, and user data validation.

---

For more details, see the comments in the source files. 