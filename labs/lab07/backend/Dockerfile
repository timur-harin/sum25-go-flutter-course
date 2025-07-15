# Build stage
# TODO: Add build stage

# Final image
# TODO: Add final image instructions


# ----------- Build stage -----------
FROM golang:1.22 AS builder

WORKDIR /app
COPY . .

RUN go mod init example.com/hello || true
RUN go build -o hello main.go

# ----------- Final image -----------
FROM gcr.io/distroless/base-debian12

WORKDIR /
COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
