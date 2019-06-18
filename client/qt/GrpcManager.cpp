#include "GrpcManager.h"

GrpcManager::GrpcManager(QObject *parent)
    : QObject(parent)
    , mClient(grpc::CreateChannel("localhost:8000", grpc::InsecureChannelCredentials()))
{}

QString GrpcManager::send(const QString& name)
{
    return QString::fromStdString(mClient.hello(name.toStdString()));
}
