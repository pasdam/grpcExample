package main

import (
	"log"
	"net"

	"../gen/go"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type greetingServer struct {
}

// Returns a greeting message
func (g *greetingServer) Hello(ctx context.Context, r *example.GreetingRequest) (*example.GreetingReply, error) {
	log.Println("Hello called")
	return &example.GreetingReply{Text: "Hello " + r.Name}, nil
}

func main() {
	lis, err := net.Listen("tcp", "localhost:9001")
	if err != nil {
		panic(err)
	}

	log.Println("Starting server")
	s := grpc.NewServer()
	example.RegisterGreeterServer(s, &greetingServer{})
	s.Serve(lis)
}
