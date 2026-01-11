# Build stage
# Add build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o main .


# Final image
# Add final image instructions
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]