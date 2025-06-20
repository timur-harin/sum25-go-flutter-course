#!/bin/bash

# Summer 2025 Go + Flutter Course - Development Setup Script

set -e

echo "🚀 Setting up Summer 2025 Go + Flutter Course development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Go installation
check_go() {
    print_status "Checking Go installation..."
    if command_exists go; then
        GO_VERSION=$(go version | cut -d' ' -f3)
        print_success "Go is installed: $GO_VERSION"
        
        # Check if version is 1.24.3 or higher
        REQUIRED_VERSION="1.24.3"
        if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
            print_warning "Go version $GO_VERSION detected. Recommended: $REQUIRED_VERSION+"
        fi
    else
        print_error "Go is not installed. Please install Go 1.24.3+ from https://golang.org/dl/"
        exit 1
    fi
}

# Check Flutter installation
check_flutter() {
    print_status "Checking Flutter installation..."
    if command_exists flutter; then
        FLUTTER_VERSION=$(flutter --version | head -n1 | cut -d' ' -f2)
        print_success "Flutter is installed: $FLUTTER_VERSION"
        
        # Check if version is 3.32.1 or higher
        REQUIRED_VERSION="3.32.1"
        if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
            print_warning "Flutter version $FLUTTER_VERSION detected. Recommended: $REQUIRED_VERSION+"
        fi
    else
        print_error "Flutter is not installed. Please install Flutter 3.32.1+ from https://flutter.dev/docs/get-started/install"
        exit 1
    fi
}

# Check Docker installation
check_docker() {
    print_status "Checking Docker installation..."
    if command_exists docker; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_success "Docker is installed: $DOCKER_VERSION"
        
        # Check if Docker daemon is running
        if ! docker info >/dev/null 2>&1; then
            print_warning "Docker daemon is not running. Please start Docker."
        fi
    else
        print_error "Docker is not installed. Please install Docker from https://docs.docker.com/get-docker/"
        exit 1
    fi
}

# Check PostgreSQL client
check_postgresql() {
    print_status "Checking PostgreSQL client..."
    if command_exists psql; then
        PSQL_VERSION=$(psql --version | cut -d' ' -f3)
        print_success "PostgreSQL client is installed: $PSQL_VERSION"
    else
        print_warning "PostgreSQL client (psql) not found. You can install it separately or use Docker."
    fi
}

# Install Go dependencies
setup_backend() {
    print_status "Setting up backend dependencies..."
    cd backend
    go mod download
    go mod tidy
    print_success "Backend dependencies installed"
    cd ..
}

# Install Flutter dependencies
setup_frontend() {
    print_status "Setting up frontend dependencies..."
    cd frontend
    flutter pub get
    print_success "Frontend dependencies installed"
    cd ..
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    # Backend directories
    mkdir -p backend/internal/models
    mkdir -p backend/internal/services
    mkdir -p backend/pkg/utils
    mkdir -p backend/migrations
    
    # Frontend directories
    mkdir -p frontend/test/unit
    mkdir -p frontend/test/widget
    mkdir -p frontend/integration_test
    
    print_success "Directories created"
}

# Set up Git hooks (optional)
setup_git_hooks() {
    print_status "Setting up Git hooks..."
    if [ -d ".git" ]; then
        # Create pre-commit hook for linting
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running pre-commit checks..."

# Run Go linting
cd backend && go fmt ./... && go vet ./...
if [ $? -ne 0 ]; then
    echo "Go linting failed"
    exit 1
fi

# Run Flutter linting
cd ../frontend && dart format --set-exit-if-changed . && dart analyze
if [ $? -ne 0 ]; then
    echo "Flutter linting failed"
    exit 1
fi

echo "Pre-commit checks passed"
EOF
        chmod +x .git/hooks/pre-commit
        print_success "Git hooks installed"
    else
        print_warning "Not a Git repository. Skipping Git hooks setup."
    fi
}

# Main setup process
main() {
    echo "🎯 Summer 2025 Go + Flutter Course Setup"
    echo "========================================"
    
    # Check prerequisites
    check_go
    check_flutter
    check_docker
    check_postgresql
    
    # Setup project
    create_directories
    setup_backend
    setup_frontend
    setup_git_hooks
    
    print_success "✅ Setup completed successfully!"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Start development environment: make dev"
    echo "  2. Open backend in one terminal: make backend-dev"
    echo "  3. Open frontend in another terminal: make frontend-dev"
    echo "  4. Visit http://localhost:3000 to see the Flutter app"
    echo "  5. Visit http://localhost:8080/health to test the Go API"
    echo ""
    echo "📖 For more information, see docs/README.md"
}

# Run main function
main "$@" 