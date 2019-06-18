package main

import (
	"fmt"
	"log"
	"net"
	"os"

	"github.com/pasdam/grpcExample/server/gen/example"
	"golang.org/x/net/context"
	"google.golang.org/grpc"
)

type greetingServer struct {
	greetSuffix string
}

// Returns a greeting message
func (g *greetingServer) Hello(ctx context.Context, r *example.GreetingRequest) (*example.GreetingReply, error) {
	log.Println("Hello called")
	return &example.GreetingReply{Text: fmt.Sprintf("Hello %s%s", r.Name, g.greetSuffix)}, nil
}

func main() {
	lis, err := net.Listen("tcp", ":8000")
	if err != nil {
		panic(err)
	}

	greetSuffix := os.Getenv("SERVER_NAME")
	if len(greetSuffix) > 0 {
		greetSuffix = fmt.Sprintf(". This is %s", greetSuffix)
	}

	log.Println("Starting server")
	s := grpc.NewServer()
	example.RegisterGreeterServer(s, &greetingServer{greetSuffix: greetSuffix})
	s.Serve(lis)
}
