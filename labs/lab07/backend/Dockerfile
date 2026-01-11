# Build stage
FROM golang:1.21-alpine AS builder

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build the Go binary
RUN go build -o main .

# Final imagedock
FROM alpine:latest

# Set working directory
WORKDIR /root/

# Copy the compiled binary from the builder
COPY --from=builder /app/main .

# Command to run the executable
CMD ["./main"]
