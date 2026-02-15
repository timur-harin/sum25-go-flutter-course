# Build stage
# TODO: Add build stage

# Final image
# TODO: Add final image instructions
# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o hello-app main.go

# Final image
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/hello-app .
ENTRYPOINT ["./hello-app"]