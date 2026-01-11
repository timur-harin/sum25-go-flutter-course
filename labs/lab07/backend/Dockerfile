FROM golang:1.23-alpine AS builder

WORKDIR /app

COPY main.go .

RUN go mod init hello-world
RUN go build -o main .


FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main .

CMD ["./main"]