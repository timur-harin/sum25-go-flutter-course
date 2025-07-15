# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./


RUN go mod download

COPY main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/hello .

# Final image
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["sh", "-c", "./hello; while true; do sleep 1; done"]
