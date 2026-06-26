#include "simulationengine.h"

#include <QDate>
#include <QDateTime>
#include <QRandomGenerator>
#include <QTime>
#include <QtMath>

static double randomBetween(double min, double max)
{
    return min + QRandomGenerator::global()->generateDouble() * (max - min);
}

SimulationEngine::SimulationEngine(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &SimulationEngine::updateSimulation);
    initStaticData();
    updateSimulation();
}

double SimulationEngine::currentPowerW() const { return m_currentPowerW; }
double SimulationEngine::todayKwh() const { return m_todayKwh; }
double SimulationEngine::todayCost() const { return m_todayCost; }
double SimulationEngine::compareYesterday() const { return m_compareYesterday; }
int SimulationEngine::activeDeviceCount() const { return m_activeDeviceCount; }
int SimulationEngine::roomCount() const { return m_roomCount; }
int SimulationEngine::alertCount() const { return m_alertCount; }
double SimulationEngine::pricePerKwh() const { return m_pricePerKwh; }

QVariantList SimulationEngine::roomConsumption() const { return m_roomConsumption; }
QVariantList SimulationEngine::dayLinePoints() const { return m_dayLinePoints; }
QVariantList SimulationEngine::weekBars() const { return m_weekBars; }
QVariantList SimulationEngine::historyLinePoints() const { return m_historyLinePoints; }
QVariantList SimulationEngine::deviceConsumption() const { return m_deviceConsumption; }
QVariantList SimulationEngine::alerts() const { return m_alerts; }

void SimulationEngine::start()
{
    if (!m_timer.isActive())
        m_timer.start();
}

void SimulationEngine::resetToday()
{
    m_todayKwh = 0.0;
    m_todayCost = 0.0;
    m_dayLinePoints.clear();
    emit dataChanged();
}

void SimulationEngine::rescanDevices()
{
    emit scanChanged();
}

void SimulationEngine::setPricePerKwh(double pricePerKwh)
{
    double sanitizedPrice = qBound(0.0, pricePerKwh, 100000.0);
    if (qFuzzyCompare(m_pricePerKwh + 1.0, sanitizedPrice + 1.0))
        return;

    m_pricePerKwh = sanitizedPrice;
    m_todayCost = m_todayKwh * m_pricePerKwh;
    emit dataChanged();
}

void SimulationEngine::initStaticData()
{
    m_roomConsumption = {
        QVariantMap{{"name", "Phòng khách"}, {"kwh", 7.2}, {"percent", 38}, {"icon", "🛋️"}},
        QVariantMap{{"name", "Phòng ngủ"}, {"kwh", 4.1}, {"percent", 22}, {"icon", "🛏️"}},
        QVariantMap{{"name", "Bếp"}, {"kwh", 3.6}, {"percent", 19}, {"icon", "🍳"}},
        QVariantMap{{"name", "Phòng giặt"}, {"kwh", 2.2}, {"percent", 12}, {"icon", "🧺"}},
        QVariantMap{{"name", "Phòng tắm"}, {"kwh", 1.6}, {"percent", 9}, {"icon", "🛁"}}
    };

    m_weekBars.clear();
    QStringList labels = {"T2", "T3", "T4", "T5", "T6", "T7", "CN"};
    QList<double> values = {23, 26, 29, 24, 28, 22, 19};
    for (int i = 0; i < labels.size(); ++i)
        m_weekBars.append(QVariantMap{{"label", labels[i]}, {"value", values[i]}});

    m_deviceConsumption = {
        QVariantMap{{"name", "Điều hòa phòng ngủ"}, {"kwh", 45.6}, {"percent", 36}},
        QVariantMap{{"name", "Tủ lạnh"}, {"kwh", 28.7}, {"percent", 23}},
        QVariantMap{{"name", "Máy giặt"}, {"kwh", 16.3}, {"percent", 13}},
        QVariantMap{{"name", "Tivi"}, {"kwh", 12.1}, {"percent", 10}},
        QVariantMap{{"name", "Quạt"}, {"kwh", 8.7}, {"percent", 7}},
        QVariantMap{{"name", "Khác"}, {"kwh", 15.0}, {"percent", 11}}
    };

    m_alerts = {
        QVariantMap{{"type", "danger"}, {"title", "Điều hòa phòng khách đã bật trên 8 giờ"}, {"desc", "Đã bật từ 01:15 15/06"}, {"time", "09:30"}},
        QVariantMap{{"type", "danger"}, {"title", "Tiêu thụ điện vượt ngưỡng"}, {"desc", "Hôm nay: 18.7 kWh (Vượt 20% so với ngưỡng)"}, {"time", "08:15"}},
        QVariantMap{{"type", "warning"}, {"title", "Tủ lạnh hoạt động bất thường"}, {"desc", "Công suất cao hơn bình thường"}, {"time", "07:45"}},
        QVariantMap{{"type", "warning"}, {"title", "Máy giặt đã hoàn thành"}, {"desc", "Chu trình giặt đã kết thúc"}, {"time", "07:20"}},
        QVariantMap{{"type", "info"}, {"title", "Rèm cửa phòng khách"}, {"desc", "Đã đóng theo lịch hẹn"}, {"time", "06:30"}}
    };

    updateHistoryData();
}

void SimulationEngine::updateSimulation()
{
    QTime now = QTime::currentTime();
    double hour = now.hour() + now.minute() / 60.0 + now.second() / 3600.0;

    double eveningPeak = 480.0 * qSin((hour - 5.5) / 24.0 * 2.0 * M_PI);
    double appliancePulse = 220.0 * qSin(QDateTime::currentMSecsSinceEpoch() / 9000.0);
    double noise = randomBetween(-90.0, 160.0);
    m_currentPowerW = qBound(120.0, 780.0 + eveningPeak + appliancePulse + noise, 3600.0);

    // Mỗi giây thật tương đương khoảng 1 phút mô phỏng để số kWh thay đổi rõ khi demo.
    double simulatedHours = 60.0 / 3600.0;
    m_todayKwh += (m_currentPowerW / 1000.0) * simulatedHours;
    m_todayCost = m_todayKwh * m_pricePerKwh;

    QVariantMap point;
    point["label"] = now.toString("HH:mm");
    point["value"] = m_currentPowerW / 1000.0;
    m_dayLinePoints.append(point);
    if (m_dayLinePoints.size() > 36)
        m_dayLinePoints.removeFirst();

    updateRoomConsumption();
    updateWeekData();
    updateHistoryData();

    emit dataChanged();
}

void SimulationEngine::updateRoomConsumption()
{
    QList<double> ratios = {0.38, 0.22, 0.19, 0.12, 0.09};
    QStringList names = {"Phòng khách", "Phòng ngủ", "Bếp", "Phòng giặt", "Phòng tắm"};
    QStringList icons = {"🛋️", "🛏️", "🍳", "🧺", "🛁"};

    m_roomConsumption.clear();
    for (int i = 0; i < names.size(); ++i) {
        double value = m_todayKwh * ratios[i] + randomBetween(-0.05, 0.05);
        int percent = qRound(ratios[i] * 100.0);
        m_roomConsumption.append(QVariantMap{{"name", names[i]}, {"kwh", qMax(0.0, value)}, {"percent", percent}, {"icon", icons[i]}});
    }
}

void SimulationEngine::updateWeekData()
{
    int idx = QDate::currentDate().dayOfWeek() - 1;
    if (idx >= 0 && idx < m_weekBars.size()) {
        QVariantMap m = m_weekBars[idx].toMap();
        m["value"] = qMax(1.0, m_todayKwh);
        m_weekBars[idx] = m;
    }
}

void SimulationEngine::updateHistoryData()
{
    m_historyLinePoints.clear();
    QList<double> values = {0.4, 0.6, 0.9, 1.1, 1.7, 1.8, 1.4, 1.5, 1.2, 1.4, 0.9, 1.3, 0.8, 0.6, 0.4};
    for (int i = 0; i < values.size(); ++i) {
        int h = i * 2;
        m_historyLinePoints.append(QVariantMap{{"label", QString("%1").arg(h, 2, 10, QChar('0'))},
                                                {"value", values[i] + randomBetween(-0.05, 0.05)}});
    }
}
