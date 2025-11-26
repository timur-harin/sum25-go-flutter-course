# Dockerfile.optimized
FROM golang:1.21-alpine AS builder
WORKDIR /app
# Copy dependency files first for better caching
COPY go.mod ./
RUN go mod download
# Copy source code
COPY . .
# Build the binary
RUN go build -o main main.go

# Final stage
FROM scratch
COPY --from=builder /app/main /main
ENTRYPOINT ["/main"]