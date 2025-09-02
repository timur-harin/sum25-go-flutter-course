# syntax=docker/dockerfile:1

# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o hello-world main.go

# Final image
FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/hello-world .
CMD ["./hello-world"]