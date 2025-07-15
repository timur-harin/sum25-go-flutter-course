# Build Stage
FROM golang:1.22 AS builder
WORKDIR /app
COPY main.go .
COPY go.mod .
RUN go mod tidy
RUN go build -o hello-app main.go

# Final Image
FROM debian:bookworm-slim AS final
WORKDIR /app
COPY --from=builder /app/hello-app .
EXPOSE 8080
CMD ["./hello-app"]
