#include <iostream>
#include <memory>
#include <string>

#include <grpc++/grpc++.h>

#include "GreeterClientCli.h"

#include "../../gen/greeting.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;
using example::GreetingRequest;
using example::GreetingReply;

int main(int argc, char** argv) {
  // Instantiate the client. It requires a channel, out of which the actual RPCs
  // are created. This channel models a connection to an endpoint (in this case,
  // localhost at port 9001). We indicate that the channel isn't authenticated
  // (use of InsecureChannelCredentials()).
  GreeterClientCli greeter(grpc::CreateChannel("localhost:9001", grpc::InsecureChannelCredentials()));

  std::cout << "Insert name: ";
  std::string user;
  std::getline(std::cin, user);

  std::string reply = greeter.Hello(user);
  std::cout << "Greeter received: " << reply << std::endl;

  return 0;
}