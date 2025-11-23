# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY main.go .
RUN go build -o hello-world .

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/hello-world .
CMD ["./hello-world"]