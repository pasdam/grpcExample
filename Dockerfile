# Build image
########################
FROM golang:1.12.5-alpine3.9 as builder

WORKDIR /var/tmp/app

# Install dependencies
RUN apk add --no-cache \
        git \
        make \
        protobuf
RUN go get -u github.com/golang/protobuf/protoc-gen-go

# copy artifacts into the container
ADD . .

# Build the protos
RUN make proto-go

# Build the app
RUN go build -o .build/app server/main.go

# Final image
########################
FROM alpine:3.9

WORKDIR /opt/app

COPY --from=builder /var/tmp/app/.build/app .

EXPOSE 8000

CMD [ "./app" ]
