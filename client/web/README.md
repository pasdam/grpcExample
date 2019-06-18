# Web client

This folder contains all the files needed to build and run the web client of the service.

To build the client just run the following command from the project root:

```sh
make client-web
```

This command will generate the javascript library used in the `index.html`.

In order to correctly forward the requests from the web client to the gRPC server we [need to use the Envoy proxy](https://blog.envoyproxy.io/envoy-and-grpc-web-a-fresh-new-alternative-to-rest-6504ce7eb880). To spin up an instance, just run the following:

```sh
docker run --rm -d --name envoy -p 9901:9901 -p 8080:8080 -v <project_root>/client/web/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy-alpine
```

The previous command works on macOS, and should work on Windows as well (untested).

On Linux the command should be (untested):

```sh
docker run --rm -d --network="host" --name envoy -v <project_root>/client/web/envoy.yaml:/etc/envoy/envoy.yaml envoyproxy/envoy-alpine
```

In this case we also need to change the `envoy.yaml` file, in particular the line:

```yaml
hosts: [{ socket_address: { address: host.docker.internal, port_value: 8000 }}]
```

should be:

```yaml
hosts: [{ socket_address: { address: localhost, port_value: 8000 }}]
```
