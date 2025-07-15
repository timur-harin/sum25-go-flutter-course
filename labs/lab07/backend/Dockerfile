# Start from the official Go image
FROM golang:1.22-alpine

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build Go app
RUN go build -o main .

# Run the app
CMD ["./main"]
