# Build stage
# TODO: Add build stage
FROM golang:1.22 as builder

WORKDIR /app
COPY . .

RUN go build -o main

# Final image
# TODO: Add final image instructions

FROM debian:bullseye-slim

WORKDIR /app
COPY --from=builder /app/main .

CMD ["./main"]