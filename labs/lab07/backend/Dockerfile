FROM golang:latest

WORKDIR /app

COPY . .

RUN go mod download

RUN go build -o my-hello-world-app .

CMD ["/app/my-hello-world-app"]