# Build stage
FROM golang:1.21 as builder
WORKDIR /app
COPY . .
RUN go build -o main .

# Final image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]