@@ -1,5 +1,14 @@
# Build stage
# TODO: Add build stage
FROM golang:1.22 AS builder

# Final image
# TODO: Add final image instructions 
WORKDIR /app
COPY . .

RUN go mod init example.com/hello || true
RUN go build -o hello main.go

FROM gcr.io/distroless/base-debian12

WORKDIR /
COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]