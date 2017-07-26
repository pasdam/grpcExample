# Qt qmake integration with Google Protocol Buffers compiler protoc
#
# To compile protocol buffers with qt qmake, specify PROTOS variable and
# include this file
#
# Example:
# LIBS += /usr/lib/libprotobuf.so
# PROTOS = a.proto b.proto
# include(protobuf.pri)
#
# By default protoc looks for .proto files (including the imported ones) in
# the current directory where protoc is run. If you need to include additional
# paths specify the PROTOPATH variable
#
# Example:
# PROTOPATH += folder/with/proto

# set defaults
isEmpty(PROTOC):PROTOC = protoc
isEmpty(PROTOC_GRPC):PROTOC_GRPC = grpc_cpp_plugin
isEmpty(PROTO_OUT_DIR):PROTO_OUT_DIR = $$OUT_PWD

# create includes parameters
PROTOPATHS_PARAM =
for(path, PROTOPATH):PROTOPATHS_PARAM += --proto_path=$${path}

# generate proto/grpc files (h and cc)
protobuf_decl.input = PROTOS
protobuf_decl.output = $${PROTO_OUT_DIR}/${QMAKE_FILE_BASE}.pb.h
protobuf_decl.CONFIG = target_predeps
protobuf_decl.commands = $${PROTOC} $${PROTOPATHS_PARAM} --cpp_out=$${PROTO_OUT_DIR} --grpc_out=$${PROTO_OUT_DIR} --plugin=protoc-gen-grpc=$${PROTOC_GRPC} ${QMAKE_FILE_NAME};
protobuf_decl.commands += $$escape_expand(\n\n)
protobuf_decl.variable_out = HEADERS
QMAKE_EXTRA_COMPILERS += protobuf_decl

# the following are used to include generated files into HEADERS/SOURCES variables
# and to force qmake to clean cc/grpc files
protobuf_clean_impl.input = PROTOS
protobuf_clean_impl.output = $${PROTO_OUT_DIR}/${QMAKE_FILE_BASE}.pb.cc
protobuf_clean_impl.commands = $$escape_expand(\n\n)
protobuf_clean_impl.variable_out = SOURCES
protobuf_clean_grpc_decl.input = PROTOS
protobuf_clean_grpc_decl.output = $${PROTO_OUT_DIR}/${QMAKE_FILE_BASE}.grpc.pb.h
protobuf_clean_grpc_decl.commands = $$escape_expand(\n\n)
protobuf_clean_grpc_decl.variable_out = HEADERS
protobuf_clean_grpc_impl.input = PROTOS
protobuf_clean_grpc_impl.output = $${PROTO_OUT_DIR}/${QMAKE_FILE_BASE}.grpc.pb.cc
protobuf_clean_grpc_impl.commands = $$escape_expand(\n\n)
protobuf_clean_grpc_impl.variable_out = SOURCES
QMAKE_EXTRA_COMPILERS += protobuf_clean_impl protobuf_clean_grpc_decl protobuf_clean_grpc_impl
