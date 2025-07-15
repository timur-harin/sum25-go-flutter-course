# Build stage
FROM golang:1.21 as builder
WORKDIR /app
COPY . .
RUN go build -o hello

# Final image
FROM debian:bullseye-slim
COPY --from=builder /app/hello /hello
CMD ["/hello"]
