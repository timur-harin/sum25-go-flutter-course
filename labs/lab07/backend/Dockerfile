# Этап сборки
FROM golang:1.21 AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . ./
RUN go build -o main .

# Финальный образ
FROM gcr.io/distroless/base-debian11

WORKDIR /app

COPY --from=builder /app/main .

CMD ["/app/main"]