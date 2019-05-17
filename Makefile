PROJECT_NAME = grpc-example

HOST_SYSTEM = $(shell uname | cut -f 1 -d_)
SYSTEM     ?= $(HOST_SYSTEM)
CXX         = g++
CXXFLAGS   += -I/usr/local/include -pthread -std=c++11
ifeq ($(SYSTEM), Darwin)
LDFLAGS    += -L/usr/local/lib `pkg-config --libs grpc++ grpc` \
				-lgrpc++_reflection                              \
				-lprotobuf -lpthread -ldl
else
LDFLAGS    += -L/usr/local/lib `pkg-config --libs grpc++ grpc`       \
				-Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed \
				-lprotobuf -lpthread -ldl
endif
PROTOC                = protoc
PLUGIN_GRPC_CPP       = grpc_cpp_plugin
PLUGIN_GO             = protoc-gen-go
PLUGIN_GRPC_WEB       = protoc-gen-grpc-web
PLUGIN_GRPC_CPP_PATH ?= `which $(PLUGIN_GRPC_CPP)`

WEB_DIR               = ./client/web
OUT_DIR               = ./gen
OUT_CPP               = $(OUT_DIR)/cpp
OUT_GO                = server/gen/example
OUT_WEB               = $(WEB_DIR)/gen
PROTOS_PATH           = ./protocol

vpath %.proto $(PROTOS_PATH)

include scripts/makefiles/third_party/pasdam/makefiles/docker.mk
include scripts/makefiles/third_party/pasdam/makefiles/help.mk

################
# Main targets #
################

.PHONY : all
all: client-cli client-web server

.PHONY: clean
clean:
	rm -rf $(OUT_GO)
	rm -rf $(OUT_DIR)
	rm -rf $(OUT_WEB)
	rm -rf $(WEB_DIR)/dist

client-cli: $(OUT_CPP)/greeting.pb.o $(OUT_CPP)/greeting.grpc.pb.o $(OUT_CPP)/client-cli.o
	$(CXX) $^ $(LDFLAGS) -I$(OUT_CPP) -o $(OUT_CPP)/$@

.PHONY: client-web
client-web: $(WEB_DIR)/dist/main.js

.PHONY: proto
proto: $(OUT_CPP)/greeting.pb.cc $(OUT_CPP)/greeting.grpc.pb.cc $(OUT_GO)/greeting.pb.go | check-system

.PHONY: proto-go
proto-go: $(OUT_GO)/greeting.pb.go

server: $(OUT_GO)/greeting.pb.go
	@go build -o $(OUT_GO)/server server/main.go

.PHONY: start-client-cli
start-client-cli: | client-cli
	@$(OUT_CPP)/client-cli

.PHONY: start-server
start-server: | server
	@$(OUT_GO)/server

########################
# Intermediate targets #
########################

$(OUT_CPP)/client-cli.o: client/cli/main.cpp
	$(CXX) $(CXXFLAGS) -I$(OUT_CPP) -c -o $@ $^

$(WEB_DIR)/dist/main.js: $(WEB_DIR)/client.js $(WEB_DIR)/package-lock.json $(OUT_WEB)/greeting_pb.js $(OUT_WEB)/greeting_grpc_web_pb.js
	@cd $(WEB_DIR) && npx webpack client.js --mode development

$(WEB_DIR)/package-lock.json: $(WEB_DIR)/package.json
	@cd $(WEB_DIR) && npm install

#################
# Proto compile #
#################

# C++: protobuf
.PRECIOUS: $(OUT_CPP)/%.pb.cc $(OUT_CPP)/%.grpc.pb.cc
$(OUT_CPP)/%.pb.cc $(OUT_CPP)/%.grpc.pb.cc: $(PROTOS_PATH)/%.proto | $(OUT_CPP) check-cpp-grpc
	$(PROTOC) -I $(PROTOS_PATH) --cpp_out=$(OUT_CPP) --grpc_out=$(OUT_CPP) --plugin=protoc-gen-grpc=$(PLUGIN_GRPC_CPP_PATH) $<

# Go
.PRECIOUS: $(OUT_GO)/%.pb.go
$(OUT_GO)/%.pb.go: $(PROTOS_PATH)/%.proto | $(OUT_GO) check-protoc-go
	$(PROTOC) -I $(PROTOS_PATH) --go_out=plugins=grpc:$(OUT_GO) $<

# Web
.PRECIOUS: $(OUT_WEB)/%_pb.js $(OUT_WEB)/%_grpc_web_pb.js
$(OUT_WEB)/%_pb.js $(OUT_WEB)/%_grpc_web_pb.js: $(PROTOS_PATH)/%.proto | $(OUT_WEB) check-protoc-web
	$(PROTOC) -I $(PROTOS_PATH) --js_out=import_style=commonjs:$(OUT_WEB) --grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(OUT_WEB) $<

########################
# Prerequisites checks #
########################

.PHONY: check-system
check-system: check-cpp-grpc check-protoc-go check-protoc-web

# Check gRPC plugin
HAS_PLUGIN_GRPC_CPP = $(shell which $(PLUGIN_GRPC_CPP) > /dev/null && echo true || echo false)
.PHONY: check-cpp-grpc
check-cpp-grpc: check-protobuf
ifneq ($(HAS_PLUGIN_GRPC_CPP), true)
	@echo
	@echo "DEPENDENCY ERROR"
	@echo
	@echo "You don't have the grpc c++ protobuf plugin installed in your path."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/grpc/grpc"
	@echo
	@false
endif

# Check Go plugin
HAS_PLUGIN_GO = $(shell which $(PLUGIN_GO) > /dev/null && echo true || echo false)
.PHONY: check-protoc-go
check-protoc-go: check-protobuf
ifneq ($(HAS_PLUGIN_GO), true)
	@echo
	@echo "DEPENDENCY ERROR"
	@echo
	@echo "You don't have the grpc Go protobuf plugin installed in your path."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/golang/protobuf"
	@echo
	@false
endif

# Check Go plugin
HAS_PLUGIN_GRPC_WEB = $(shell which $(PLUGIN_GRPC_WEB) > /dev/null && echo true || echo false)
.PHONY: check-protoc-web
check-protoc-web: check-protobuf
ifneq ($(HAS_PLUGIN_GRPC_WEB), true)
	@echo
	@echo "DEPENDENCY ERROR"
	@echo
	@echo "You don't have the grpc web protobuf plugin installed in your path."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/grpc/grpc-web"
	@echo
	@false
endif

# Check protoc
HAS_PROTOC = $(shell which $(PROTOC) > /dev/null && echo true || echo false)
ifeq ($(HAS_PROTOC),true)
HAS_PROTOC_VALID = $(shell $(PROTOC) --version | grep -q libprotoc.3 2> /dev/null && echo true || echo false)
else
HAS_PROTOC_VALID = false
endif
.PHONY: check-protobuf
check-protobuf:
ifneq ($(HAS_PROTOC_VALID), true)
	@echo
	@echo "DEPENDENCY ERROR"
	@echo
	@echo "You don't have protoc 3.x.x installed in your path."
	@echo "Please install Google protocol buffers 3.x.x and its compiler."
	@echo "You can find it here:"
	@echo
	@echo "   https://github.com/google/protobuf/releases/"
	@echo
	@false
endif

# Check required directories
$(OUT_CPP):
	mkdir -p $(OUT_CPP)
$(OUT_GO):
	mkdir -p $(OUT_GO)
$(OUT_WEB):
	mkdir -p $(OUT_WEB)
