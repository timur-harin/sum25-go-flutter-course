
FROM golang:1.21-alpine AS build
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o hello

FROM alpine:latest
COPY --from=build /app/hello /hello
CMD ["/hello"]