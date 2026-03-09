# Build stage
FROM golang:1.22 AS builder
WORKDIR /app
COPY . .
RUN go build -o hello

# Final image
FROM debian:bullseye-slim
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]
