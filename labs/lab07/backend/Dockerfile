# Build stage
# TODO: Add build stage
FROM golang:latest AS builder
WORKDIR /backend
COPY go.mod ./
RUN go mod download
RUN go mod tidy
COPY . .
RUN go build -o main .

# Final image
# TODO: Add final image instructions
FROM alpine:latest
WORKDIR /backend
COPY --from=builder /backend/main .
EXPOSE 8080
CMD ["./main"]