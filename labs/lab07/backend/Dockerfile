# Build stage
FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .

RUN go build -o hello .

# Final image
FROM gcr.io/distroless/base-debian11

WORKDIR /

COPY --from=builder /app/hello /hello

EXPOSE 8080

ENTRYPOINT ["/hello"]