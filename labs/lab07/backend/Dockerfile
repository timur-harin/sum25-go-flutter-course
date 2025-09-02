FROM golang:1.21 as builder

WORKDIR /app

COPY go.mod ./
COPY main.go ./

RUN go mod tidy
RUN go build -o main .

# Финальный минимальный образ
FROM alpine:latest
WORKDIR /root/

COPY --from=builder /app/main .

CMD ["./main"]