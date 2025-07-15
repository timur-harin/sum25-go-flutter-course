FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o main .

FROM gcr.io/distroless/static
COPY --from=builder /app/main /
CMD ["/main"]
