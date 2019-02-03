# GrpcExample

This repository contains an example of a service defined with gRPC, it's my playground to explore gRPC implementation in different languages.

As of now it contains a server written in Go, and three clients, a command line one, one with a GUI written with Qt/QML, and a web one.

DISCLAIMER: this is a quick hack, it's just a showcase, the project doesn't necessarily follow all the best practices.

## Requirements

Minimum:

* make;
* [Go 1.8.3](https://golang.org/dl/);
* [gRPC-go](https://github.com/golang/protobuf/);
* pkg-config;
* [Protobuf 3.3.2](https://github.com/protocolbuffers/protobuf/releases).

Requirements for the command line client:

* [gRPC-c++](https://grpc.io/docs/quickstart/cpp.html).

Requirements for the GUI client:

* [Qt 5.9](https://www.qt.io/download).

Requirements for the web client:

* [Docker](https://docs.docker.com/install/);
* [gRPC-web](https://github.com/grpc/grpc-web);
* [npm](https://nodejs.org/en/download/).

Note: the code might works also with previous versions, but it was tested only with the specified ones.

## Project structure

```dir
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

```sh
make
```

It is also possible to run each target separately:

```sh
make <target>
```

The available targets are:

* _client-cli_: to build the command line client;
* _client-web_: to build the javascript client to use in the browser;
* _proto_: to build the proto files and generate the source for each target language (c++/go/web);
* _server_: to build the server;
* _start-client-cli_: to start the command line client;
* _start-server_: to start the server.

To build the Qt client, simply just open _client/qt/GRPCExample.pro_ with QtCreator and press run.

## Web client

To read detailed information about the web client, please read the related [README](client/web/README.md).
