# Build stage
# TODO: Add build stage

# Final image
# TODO: Add final image instructions
FROM golang:1.22-alpine

WORKDIR /app

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]