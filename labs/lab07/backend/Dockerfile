# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o hello main.go
# Final image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/hello .
EXPOSE 8080
CMD ["./hello"]
