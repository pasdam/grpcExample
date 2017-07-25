# GrpcExample
This repository contains an example of a service defined with gRPC, a server written in Go, and two clients, a command line one and one with a GUI, this latter written with Qt/QML.

## Requirements
* gRPC 1.4.2;
* Go 1.8.3;
* Protobuf 3.3.2;
* Qt 5.9.
Note: the code might works also with previous versions, but it was tested only with the specified ones.

## Project structure
```
- client
  |- cli
  |- core
  |- qt
- protocol
- server
```
The _client/cli_ folder contains the command line c++ client, whereas the Qt one is in _client/qt_; _client/core_ contains files shared between the two clients. The _protocol_ folder contains the proto/gRPC definitions. And finally the _server_ directory contains the server written in Go.

## Build
To build the server and the command line client is possible to use the included _Makefile_:
```bash
make
```
This command will basically execute the following:
```bash
mkdir -p gen/go
protoc --proto_path=./protocol --cpp_out=./gen --go_out=plugins=grpc:./gen/go --grpc_out=./gen --plugin=protoc-gen-grpc=`which grpc_cpp_plugin` ./protocol/greeting.proto
```
It is also possible to build each targets separately. To build the protos, just run:
```bash
make proto
```
To build the server:
```bash
make server
```
To build the command line client:
```bash
make client-cli
```

To build the Qt client, simply just open _client/qt/GRPCExample.pro_ with QtCreator and press run: it will take care of everything (hopefully...).
