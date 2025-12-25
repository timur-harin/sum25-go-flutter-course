# -------- Build stage --------
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy only go.mod and download deps (this will produce a go.sum in-container)
COPY go.mod ./
RUN go mod download

# Copy the rest of your source and build statically
COPY . .
RUN CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64 \
    go build -ldflags="-s -w" -o lab07-backend

# -------- Final image --------
FROM scratch

# Copy the built binary out of the builder
COPY --from=builder /app/lab07-backend /lab07-backend

ENTRYPOINT ["/lab07-backend"]
