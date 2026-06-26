#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "simulationengine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    SimulationEngine simulationEngine;
    engine.rootContext()->setContextProperty("simulationEngine", &simulationEngine);
    simulationEngine.start();

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() { QCoreApplication::exit(-1); },
                     Qt::QueuedConnection);

    engine.loadFromModule("SmartHome", "Main");

    return app.exec();
}
