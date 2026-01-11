FROM golang:1.22 as builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o hello
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/hello .
CMD ["./hello"]

