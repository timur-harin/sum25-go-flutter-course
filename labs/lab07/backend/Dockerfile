FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /app

COPY go.mod ./

RUN go mod download

COPY . .

RUN go build -o ./main ./main.go 

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/main ./

CMD ["./main"]