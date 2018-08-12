HOST_SYSTEM = $(shell uname | cut -f 1 -d_)
SYSTEM ?= $(HOST_SYSTEM)
CXX = g++
CXXFLAGS += -I/usr/local/include -pthread -std=c++11
ifeq ($(SYSTEM),Darwin)
LDFLAGS += -L/usr/local/lib `pkg-config --libs grpc++ grpc` \
		   -lgrpc++_reflection                              \
		   -lprotobuf -lpthread -ldl
else
LDFLAGS += -L/usr/local/lib `pkg-config --libs grpc++ grpc`       \
		   -Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed \
		   -lprotobuf -lpthread -ldl
endif
PROTOC = protoc
GRPC_CPP_PLUGIN = grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

OUT_DIR = ./gen
OUT_GO = $(OUT_DIR)/go
PROTOS_PATH = ./protocol

vpath %.proto $(PROTOS_PATH)

.PHONY : all
all: client-cli server

# client-cli: $(OUT_DIR)/greeting.pb.o $(OUT_DIR)/greeting.grpc.pb.o client/cli/GreeterClientCli.h
client-cli: $(OUT_DIR)/greeting.pb.o $(OUT_DIR)/greeting.grpc.pb.o $(OUT_DIR)/client-cli.o
	@echo "Compiling client"
	$(CXX) $^ $(LDFLAGS) -o $(OUT_DIR)/$@

server: $(OUT_DIR)/greeting.pb.o $(OUT_DIR)/greeting.grpc.pb.o
	@echo "Compiling server"

$(OUT_DIR)/client-cli.o: client/cli/main.cpp | system-check
	$(CXX) $(CXXFLAGS) -c -o $@ $^

.PRECIOUS: $(OUT_DIR)/%.grpc.pb.cc
$(OUT_DIR)/%.grpc.pb.cc: $(PROTOS_PATH)/%.proto | system-check
	$(PROTOC) -I $(PROTOS_PATH) --go_out=plugins=grpc:$(OUT_GO) --grpc_out=$(OUT_DIR) --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

.PRECIOUS: $(OUT_DIR)/%.pb.cc
$(OUT_DIR)/%.pb.cc: $(PROTOS_PATH)/%.proto | system-check
	$(PROTOC) -I $(PROTOS_PATH) --go_out=$(OUT_GO) --cpp_out=$(OUT_DIR) $<

.PHONY: proto
proto: | system-check
	$(PROTOC) -I $(PROTOS_PATH) --go_out=$(OUT_GO) --cpp_out=$(OUT_DIR) protocol/*.proto
	$(PROTOC) -I $(PROTOS_PATH) --go_out=plugins=grpc:$(OUT_GO) --grpc_out=$(OUT_DIR) --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) protocol/*.proto

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)


# The following is to test your system and ensure a smoother experience.
# They are by no means necessary to actually compile a grpc-enabled software.

PROTOC_CMD = which $(PROTOC)
PROTOC_CHECK_CMD = $(PROTOC) --version | grep -q libprotoc.3
PLUGIN_CHECK_CMD = which $(GRPC_CPP_PLUGIN)
HAS_PROTOC = $(shell $(PROTOC_CMD) > /dev/null && echo true || echo false)
ifeq ($(HAS_PROTOC),true)
HAS_VALID_PROTOC = $(shell $(PROTOC_CHECK_CMD) 2> /dev/null && echo true || echo false)
endif
HAS_PLUGIN = $(shell $(PLUGIN_CHECK_CMD) > /dev/null && echo true || echo false)

SYSTEM_OK = false
ifeq ($(HAS_VALID_PROTOC),true)
ifeq ($(HAS_PLUGIN),true)
SYSTEM_OK = true
endif
endif

system-check:
ifneq ($(HAS_VALID_PROTOC),true)
	@echo " DEPENDENCY ERROR"
	@echo
	@echo "You don't have protoc 3.0.0 installed in your path."
	@echo "Please install Google protocol buffers 3.0.0 and its compiler."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/google/protobuf/releases/tag/v3.0.0"
	@echo
	@echo "Here is what I get when trying to evaluate your version of protoc:"
	@echo
	-$(PROTOC) --version
	@echo
	@echo
endif
ifneq ($(HAS_PLUGIN),true)
	@echo " DEPENDENCY ERROR"
	@echo
	@echo "You don't have the grpc c++ protobuf plugin installed in your path."
	@echo "Please install grpc. You can find it here:"
	@echo
	@echo "   https://github.com/grpc/grpc"
	@echo
	@echo "Here is what I get when trying to detect if you have the plugin:"
	@echo
	-which $(GRPC_CPP_PLUGIN)
	@echo
	@echo
endif
ifneq ($(SYSTEM_OK),true)
	@false
endif
	mkdir -p $(OUT_GO)
