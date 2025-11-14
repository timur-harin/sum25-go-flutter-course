# Build stage
# TODO: Add build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN go build -o printHello


# Final image
# TODO: Add final image instructions
FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/printHello .

CMD ["./printHello"]