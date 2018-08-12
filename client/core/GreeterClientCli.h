#ifndef __CLIENT_CLI_H_
#define __CLIENT_CLI_H_

#include <iostream>
#include <string>

#include <grpc++/grpc++.h>

#include "../../gen/greeting.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using example::GreetingRequest;
using example::GreetingReply;
using example::Greeter;

class GreeterClientCli {
public:
    GreeterClientCli(std::shared_ptr<Channel> channel) : stub_(Greeter::NewStub(channel)) {}

    // Assembles the client's payload, sends it and presents the response back
    // from the server.
	std::string hello(const std::string& name) {
        // Data we are sending to the server.
        GreetingRequest request;
        request.set_name(name);

        // Container for the data we expect from the server.
        GreetingReply reply;

        // Context for the client. It could be used to convey extra information to
        // the server and/or tweak certain RPC behaviors.
        ClientContext context;

        // The actual RPC.
        Status status = stub_->Hello(&context, request, &reply);

        // Act upon its status.
        if (status.ok()) {
            return reply.text();

        } else {
            std::cout << status.error_code() << ": " << status.error_message() << std::endl;
            return "RPC failed";
        }
    }

private:
    std::unique_ptr<Greeter::Stub> stub_;
};

#endif // __CLIENT_CLI_H_
