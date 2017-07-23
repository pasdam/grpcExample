#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <GrpcManager.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    GrpcManager grpcManager;
    engine.rootContext()->setContextProperty("grpcManager", &grpcManager);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
