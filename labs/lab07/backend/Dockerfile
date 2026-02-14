# Build stage
FROM golang:1.20-alpine AS build

WORKDIR /app

# Copy the source code
COPY main.go ./

# Build the Go app
RUN go build -o hello-world-app main.go

# Final image
FROM alpine:latest

# Install ca-certificates for HTTPS support if needed
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from the build stage
COPY --from=build /app/hello-world-app .

# Command to run the binary
CMD ["./hello-world-app"]
