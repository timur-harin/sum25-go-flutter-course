# Summer 2025 Go + Flutter Course

A comprehensive 8-blocks intensive course teaching modern full-stack development with Go backend and Flutter frontend, emphasizing real-world software engineering practices.

## 🎯 Course Overview

This course is designed for 1st/2nd year students to build practical skills in:
- **Backend Development**: Go with RESTful APIs, databases, and microservices
- **Frontend Development**: Flutter for cross-platform applications
- **DevOps**: Docker containerization, CI/CD pipelines, automated testing
- **Database Management**: PostgreSQL with migrations and optimization
- **Software Engineering**: Code review, testing, documentation, and collaboration

## 📚 Course Structure

### 8 blocks
Each block consists of:
- **1 Lecture** (1.5 hours): Deep theory, concepts, and comprehensive code examples
- **1 Lab** (1.5 hours): Extended hands-on implementation with **both Go and Flutter**

**Block 1**: Foundations
- Go: Basic syntax, functions, structs, packages
- Flutter: Widgets, layouts, basic UI components, stateful/stateless widgets
- Integration: None
- **Deep Dive**: Memory management, Go idioms, Flutter widget lifecycle

**Block 2**: Concurrency & Streams
- Go: Goroutines, channels, select statements, worker pools, context package
- Flutter: Async/await, futures, streams, StreamBuilder
- Integration: Concurrent API calls and real-time data updates
- **Deep Dive**: Advanced concurrency patterns, stream transformations

**Block 3**: Data & APIs
- Go: HTTP servers, routing, middleware, JSON APIs, validation, error handling
- Flutter: HTTP client, data models, serialization, caching
- Integration: RESTful API communication and robust data handling
- **Deep Dive**: API design patterns, advanced serialization, performance

**Block 4**: Database & Persistence
- Go: PostgreSQL integration, GORM, migrations, transactions
- Flutter: Local storage, SQLite, data caching
- Integration: CRUD operations
- **Deep Dive**: Database optimization, complex queries, data architecture

**Block 5**: Advanced Patterns & Testing
- Go: Clean architecture, dependency injection, testing, mocking
- Flutter: State management (Riverpod+Bloc), testing, navigation
- Integration: End-to-end testing
- **Deep Dive**: Design patterns, advanced testing strategies, code quality

**Block 6**: Authentication & Security
- Go: JWT tokens, password hashing, middleware, validation, security best practices
- Flutter: Authentication flow, secure storage, session management
- Integration: Secure user authentication and authorization
- **Deep Dive**: Security vulnerabilities, encryption, secure coding practices

**Block 7**: WebSockets & gRPC
- Go: WebSocket servers, gRPC services, Protocol Buffers, streaming APIs
- Flutter: WebSocket clients, gRPC client integration, real-time updates
- Integration: Real-time communication and high-performance API calls
- **Deep Dive**: gRPC streaming, WebSocket scaling, performance optimization

**Block 8**: Docker & Production
- Go: Containerization, environment config, logging, monitoring, performance
- Flutter: Build optimization, PWA, deployment strategies, analytics
- Integration: Full production deployment with CI/CD and monitoring
- **Deep Dive**: Production best practices, scaling, observability

## 🛠 Tech Stack

- **Backend**: Go 1.24.3+, http, Gin framework, GORM, PostgreSQL, gRPC, Protocol Buffers
- **Frontend**: Flutter 3.32.1+, Riverpod(Bloc), HTTP client, gRPC client
- **Infrastructure**: Docker, Docker Compose, GitHub Actions
- **Database**: PostgreSQL 17.5+, database migrations
- **Testing**: Go testing, Flutter testing, integration tests

## 🚀 Getting Started

### Prerequisites
- Git installed and configured
- Go 1.24.3+ installed
- Flutter 3.32.1+ installed
- Docker and Docker Compose installed
- PostgreSQL client 

### Initial Setup
```bash
# Fork this repository to your GitHub account
# Clone your fork
git clone https://github.com/YOUR_USERNAME/sum25-go-flutter-course.git
cd sum25-go-flutter-course

# Install dependencies
make setup

# Start development environment
make dev
```

## 📋 Submission Workflow

This course uses a **fork-and-merge-request** workflow similar to real software development:

### 1. Fork and Setup
1. Fork this repository to your GitHub account
2. Clone your fork locally
3. Add upstream remote: `git remote add upstream https://github.com/timur-harin/sum25-go-flutter-course.git`

### 2. Lab Submission Process
1. Create a new branch for each lab: `git checkout -b lab01-surname-name` - all lowercase, no spaces, like in Moodle
2. Complete the lab requirements in the appropriate `labs/labXX/` directory
3. Ensure all tests pass: `make test`
4. Ensure code passes linting: `make lint`
5. Commit and push your changes
6. Create a Merge Request to the main repository
7. Wait for automated CI checks, peer review and instructor review

### 3. Code Review Process
- **Automated Checks**: CI pipeline runs tests, linting, and builds
- **Peer Review**: Other students review your code (required)
- **Instructor Review**: Spot-checks for edge cases and learning objectives
- **Continuous Integration**: All changes must pass automated tests

## 🏗 Repository Structure

```
sum25-go-flutter-course/
├── backend/                    # Go backend source code
│   ├── cmd/                   # Application entry points
│   ├── internal/              # Private application code
│   ├── pkg/                   # Public library code
│   ├── migrations/            # Database migrations
│   ├── tests/                 # Integration tests
│   ├── go.mod                 # Go module definition
│   └── Dockerfile             # Backend container
├── frontend/                   # Flutter frontend source code
│   ├── lib/                   # Dart source code
│   ├── test/                  # Unit and widget tests
│   ├── integration_test/      # Integration tests
│   ├── pubspec.yaml           # Flutter dependencies
│   └── Dockerfile             # Frontend container
├── labs/                       # Lab assignments and solutions
│   ├── labXX/                 # Lab XX 
│   │   ├── backend/           # Go component
│   │   ├── frontend/          # Flutter component
│   │   └── README.md          # Lab instructions
├── slides/                     # Course presentation materials
│   ├── lectureXX/             # Lecture XX
├── .github/                    # GitHub configuration
│   └── workflows/             # CI/CD pipelines
├── docs/                       # Additional documentation
├── scripts/                    # Development scripts
├── docker-compose.yml          # Local development environment
├── Makefile                   # Common development tasks
└── README.md                  # This file
```

## 🎯 Learning Objectives

By the end of this course, students will be able to:
- Build and deploy full-stack applications using Go and Flutter
- Master Go concurrency with goroutines and channels
- Implement async programming and streams in Flutter
- Design and implement RESTful APIs with proper architecture
- Manage databases with migrations and optimization techniques
- Implement proper testing strategies (unit, integration, E2E)
- Use version control and collaborative development workflows
- Apply DevOps practices including containerization and CI/CD
- Follow software engineering best practices and code review processes

## 📖 Resources

- [Go Documentation](https://golang.org/doc/)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Course Slides](./slides/)

## 🤝 Contributing

This course encourages collaborative learning:
- Participate actively in code reviews
- Suggest improvements to course materials
- Share useful resources and tips

## 📄 License

This course material is licensed under MIT License - see [LICENSE](LICENSE) for details. 