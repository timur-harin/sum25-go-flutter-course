.PHONY: help setup dev test lint clean build docker-build docker-up docker-down

# Default target
help:
	@echo "Available commands:"
	@echo "  setup        - Install dependencies and setup development environment"
	@echo "  dev          - Start development environment"
	@echo "  test         - Run all tests (Go + Flutter)"
	@echo "  lint         - Run linters for Go and Flutter"
	@echo "  clean        - Clean build artifacts"
	@echo "  build        - Build backend and frontend"
	@echo "  docker-build - Build Docker images"
	@echo "  docker-up    - Start services with Docker Compose"
	@echo "  docker-down  - Stop Docker Compose services"

# Setup development environment
setup:
	@echo "🚀 Setting up development environment..."
	@if command -v go >/dev/null 2>&1; then \
		echo "✓ Go is installed"; \
		cd backend && go mod download; \
	else \
		echo "❌ Go is not installed. Please install Go 1.24.3+"; \
		exit 1; \
	fi
	@if command -v flutter >/dev/null 2>&1; then \
		echo "✓ Flutter is installed"; \
		cd frontend && flutter pub get; \
	else \
		echo "❌ Flutter is not installed. Please install Flutter 3.32.1+"; \
		exit 1; \
	fi
	@if command -v docker >/dev/null 2>&1; then \
		echo "✓ Docker is installed"; \
	else \
		echo "❌ Docker is not installed. Please install Docker"; \
		exit 1; \
	fi
	@echo "✅ Setup complete!"

# Start development environment
dev:
	@echo "🔧 Starting development environment..."
	docker compose up -d postgres
	@echo "⏳ Waiting for PostgreSQL to be ready..."
	@sleep 5
	@echo "🎯 Development environment ready!"
	@echo "   • PostgreSQL: localhost:5432"
	@echo "   • Run 'make backend-dev' in another terminal for Go server"
	@echo "   • Run 'make frontend-dev' in another terminal for Flutter app"

# Backend development server
backend-dev:
	cd backend && go run cmd/server/main.go

# Frontend development server
frontend-dev:
	cd frontend && flutter run -d web-server --web-port 3000

# Run all tests
test:
	@echo "🧪 Running tests..."
	@echo "Testing Go backend..."
	cd backend && go test ./...
	@echo "Testing Flutter frontend..."
	cd frontend && flutter test
	@echo "✅ All tests passed!"

# Run linters
lint:
	@echo "🔍 Running linters..."
	@echo "Linting Go code..."
	cd backend && go vet ./...
	cd backend && go fmt ./...
	@echo "Linting Dart code..."
	cd frontend && dart analyze
	cd frontend && dart format --set-exit-if-changed .
	@echo "✅ All linting passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cd backend && go clean
	cd frontend && flutter clean
	docker compose down -v
	@echo "✅ Cleanup complete!"

# Build applications
build:
	@echo "🏗 Building applications..."
	cd backend && go build -o bin/server cmd/server/main.go
	cd frontend && flutter build web
	@echo "✅ Build complete!"

# Build Docker images
docker-build:
	@echo "🐳 Building Docker images..."
	docker compose build
	@echo "✅ Docker images built!"

# Start all services with Docker
docker-up:
	@echo "🚀 Starting all services..."
	docker compose up -d
	@echo "✅ All services started!"

# Stop Docker services
docker-down:
	@echo "🛑 Stopping services..."
	docker compose down
	@echo "✅ Services stopped!"

# Database migrations
migrate-up:
	cd backend && go run cmd/migrate/main.go up

migrate-down:
	cd backend && go run cmd/migrate/main.go down

# Generate API documentation
docs:
	cd backend && swag init -g cmd/server/main.go

# Run integration tests
test-integration:
	@echo "🔄 Running integration tests..."
	cd backend && go test -tags=integration ./tests/...
	cd frontend && flutter drive --driver=integration_test/test_driver.dart --target=integration_test/app_test.dart

# Peer Review System
peer-review:
	@echo "📋 Generating peer review assignments for all labs..."
	@cd docs/peer-review && python3 peer_review_assigner.py participants.csv
	@echo "✅ Peer review assignments generated!" 