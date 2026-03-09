FROM golang:1.22-alpine

WORKDIR /app

COPY go.mod ./
COPY go.mod ./
RUN go mod download

RUN go mod download

COPY . .

RUN go build -o hello-world

EXPOSE 8080

CMD ["./hello-world"]
