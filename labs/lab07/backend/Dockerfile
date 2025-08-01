# ---------- Build stage ----------
FROM golang:1.21 AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
RUN go build -o hello-app

# ---------- Final image ----------
FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /app/hello-app .
CMD ["./hello-app"]
