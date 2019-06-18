const { GreetingRequest, RepeatGreetingRequest, GreetingReply } = require('./gen/greeting_pb.js');
const { GreeterClient } = require('./gen/greeting_grpc_web_pb.js');

var client = new GreeterClient('http://localhost:8000', null, null);

// simple unary call
var request = new GreetingRequest();
request.setName('World');

client.hello(request, {}, (err, response) => {
    console.log(response.getText());
});
