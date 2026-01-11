# -------- Build stage --------
FROM golang:1.21 AS builder

# Initialize working dir
WORKDIR /app

# Copy go.mod and first
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the binary
RUN go build -o app .

# -------- Final image --------
FROM alpine:latest

WORKDIR /app

# Copy the compiled binary
COPY --from=builder /app/app .

# Run the binary
CMD ["./app"]
