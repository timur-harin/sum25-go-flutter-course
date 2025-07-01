# Course Documentation

Welcome to the Summer 2025 Go + Flutter Course documentation!

## 📚 Documentation Structure

- **[Setup Guide](setup.md)** - Complete setup instructions for development environment

## 🏗 Project Structure

```
sum25-go-flutter-course/
├── backend/                    # Go backend source code
│   ├── cmd/                   # Application entry points
│   │   ├── server/            # Main API server
│   │   └── migrate/           # Database migration tool
│   ├── internal/              # Private application code
│   │   ├── config/            # Configuration management
│   │   ├── handlers/          # HTTP handlers
│   │   ├── middleware/        # Custom middleware
│   │   ├── models/            # Data models
│   │   └── services/          # Business logic
│   ├── pkg/                   # Public library code
│   ├── migrations/            # Database migrations
│   └── tests/                 # Integration tests
├── frontend/                   # Flutter frontend source code
│   ├── lib/                   # Dart source code
│   │   ├── models/            # Data models
│   │   ├── screens/           # UI screens
│   │   ├── services/          # API and business logic
│   │   └── widgets/           # Reusable UI components
│   ├── test/                  # Unit and widget tests
│   └── integration_test/      # Integration tests
├── labs/                       # Lab assignments (lab01-lab08)
├── slides/                     # Course presentation materials
└── docs/                       # This documentation
```

## 🚀 Quick Start

1. **Setup Environment**
   ```bash
   make setup
   ```

2. **Start Development**
   ```bash
   make dev
   ```

3. **Run Tests**
   ```bash
   make test
   ```

4. **Lint Code**
   ```bash
   make lint
   ```

## 🎯 Course Objectives

- Master Go backend development with modern practices
- Build cross-platform Flutter applications
- Implement full-stack integration patterns
- Apply DevOps and production deployment strategies
- Practice collaborative software development workflows

## 📖 Additional Resources

- [Go Documentation](https://golang.org/doc/)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/) 