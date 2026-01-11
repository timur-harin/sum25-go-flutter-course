# Build stage
FROM golang:1.21-alpine AS builder
# Install git for private modules
RUN apk add --no-cache git
WORKDIR /app
# Copy dependency files first for better caching
COPY go.mod ./
RUN go mod download
# Copy source code
COPY . .
# Build the binary
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o main

# Final image
FROM scratch
# Add CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Add binary
COPY --from=builder /app/main /main
EXPOSE 8080
ENTRYPOINT ["/main"]


