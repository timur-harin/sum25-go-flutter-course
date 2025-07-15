module lab06-backend

go 1.23.0

toolchain go1.23.1

// Protocol buffer generation:
// protoc --go_out=. --go-grpc_out=. proto/calculator.proto

require (
	github.com/gorilla/mux v1.8.1
	github.com/gorilla/websocket v1.5.3
	google.golang.org/grpc v1.73.0
	google.golang.org/protobuf v1.36.6
)

require (
	golang.org/x/net v0.38.0 // indirect
	golang.org/x/sys v0.31.0 // indirect
	golang.org/x/text v0.23.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250324211829-b45e905df463 // indirect
)
