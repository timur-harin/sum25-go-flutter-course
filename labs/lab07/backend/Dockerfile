FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod tidy
RUN go mod download

COPY . .
RUN go build -o hello-app main.go

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/hello-app .

CMD ["./hello-app"]