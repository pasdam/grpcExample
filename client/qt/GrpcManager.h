#ifndef __GRPC_MANAGER_H_
#define __GRPC_MANAGER_H_

#include <QObject>

#include "../core/GreeterClientCli.h"

class GrpcManager : public QObject
{
    Q_OBJECT

public:
    explicit GrpcManager(QObject *parent = nullptr);

    Q_INVOKABLE QString send(const QString& name);

private:
    GreeterClientCli mClient;
};

#endif // __GRPC_MANAGER_H_
