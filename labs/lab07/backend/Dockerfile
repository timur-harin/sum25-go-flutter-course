# Build stage
# TODO: Add build stage
FROM golang:1.21 AS builder

WORKDIR /app

COPY . .
RUN go mod download

RUN go build -o app .

# Final image
# TODO: Add final image instructions

FROM alpine:latest

WORKDIR /app
RUN addgroup -S appgroup && adduser -S user -G appgroup
USER user
COPY --from=builder /app/app .

CMD ["./app"]