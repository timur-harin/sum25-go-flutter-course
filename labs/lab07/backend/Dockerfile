# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o hello

# Final image
FROM gcr.io/distroless/base-debian11
WORKDIR /
COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
