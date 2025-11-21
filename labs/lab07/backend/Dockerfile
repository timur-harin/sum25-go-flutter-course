# ---- Build Stage ----
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o hello-world main.go

# ---- Run Stage ----
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello-world .
CMD ["./hello-world"]