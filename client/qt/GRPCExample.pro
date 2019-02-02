TEMPLATE = app

QT += qml quick
CONFIG += c++11

HEADERS += \
    GrpcManager.h \
    $$PWD/../../gen/cpp/greeting.grpc.pb.h \
    $$PWD/../../gen/cpp/greeting.pb.h

SOURCES += \
    GrpcManager.cpp \
    main.cpp \
    $$PWD/../../gen/cpp/greeting.grpc.pb.cc \
    $$PWD/../../gen/cpp/greeting.pb.cc

RESOURCES += qml.qrc

INCLUDEPATH += \
    /usr/local/include \
    $$PWD/../../gen/cpp

LIBS += -L/usr/local/lib -lgrpc++ -lprotobuf
