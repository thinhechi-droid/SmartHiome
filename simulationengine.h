#ifndef SIMULATIONENGINE_H
#define SIMULATIONENGINE_H

#include <QObject>
#include <QTimer>
#include <QVariantList>

class SimulationEngine : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double currentPowerW READ currentPowerW NOTIFY dataChanged)
    Q_PROPERTY(double todayKwh READ todayKwh NOTIFY dataChanged)
    Q_PROPERTY(double todayCost READ todayCost NOTIFY dataChanged)
    Q_PROPERTY(double compareYesterday READ compareYesterday NOTIFY dataChanged)
    Q_PROPERTY(int activeDeviceCount READ activeDeviceCount NOTIFY dataChanged)
    Q_PROPERTY(int roomCount READ roomCount NOTIFY dataChanged)
    Q_PROPERTY(int alertCount READ alertCount NOTIFY dataChanged)
    Q_PROPERTY(double pricePerKwh READ pricePerKwh WRITE setPricePerKwh NOTIFY dataChanged)

    Q_PROPERTY(QVariantList roomConsumption READ roomConsumption NOTIFY dataChanged)
    Q_PROPERTY(QVariantList dayLinePoints READ dayLinePoints NOTIFY dataChanged)
    Q_PROPERTY(QVariantList weekBars READ weekBars NOTIFY dataChanged)
    Q_PROPERTY(QVariantList historyLinePoints READ historyLinePoints NOTIFY dataChanged)
    Q_PROPERTY(QVariantList deviceConsumption READ deviceConsumption NOTIFY dataChanged)
    Q_PROPERTY(QVariantList alerts READ alerts NOTIFY dataChanged)

public:
    explicit SimulationEngine(QObject *parent = nullptr);

    double currentPowerW() const;
    double todayKwh() const;
    double todayCost() const;
    double compareYesterday() const;
    int activeDeviceCount() const;
    int roomCount() const;
    int alertCount() const;
    double pricePerKwh() const;

    QVariantList roomConsumption() const;
    QVariantList dayLinePoints() const;
    QVariantList weekBars() const;
    QVariantList historyLinePoints() const;
    QVariantList deviceConsumption() const;
    QVariantList alerts() const;

    Q_INVOKABLE void start();
    Q_INVOKABLE void resetToday();
    Q_INVOKABLE void rescanDevices();
    Q_INVOKABLE void setPricePerKwh(double pricePerKwh);

signals:
    void dataChanged();
    void scanChanged();

private slots:
    void updateSimulation();

private:
    QTimer m_timer;

    double m_currentPowerW = 0.0;
    double m_todayKwh = 18.7;
    double m_todayCost = 0.0;
    double m_compareYesterday = 12.0;
    double m_pricePerKwh = 2436.0;

    int m_activeDeviceCount = 8;
    int m_roomCount = 5;
    int m_alertCount = 2;

    QVariantList m_roomConsumption;
    QVariantList m_dayLinePoints;
    QVariantList m_weekBars;
    QVariantList m_historyLinePoints;
    QVariantList m_deviceConsumption;
    QVariantList m_alerts;

    void initStaticData();
    void updateRoomConsumption();
    void updateWeekData();
    void updateHistoryData();
};

#endif // SIMULATIONENGINE_H
