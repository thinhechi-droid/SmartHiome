cmake_minimum_required(VERSION 3.21)

project(SmartHomeNE VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(SmartHomeNE
    main.cpp
    simulationengine.h
    simulationengine.cpp
)

qt_add_qml_module(SmartHomeNE
    URI SmartHome
    VERSION 1.0
    QML_FILES
        Main.qml
        LoginView.qml
        AppShell.qml
        HomeView.qml
        RoomsView.qml
        RoomDevicesView.qml
        DeviceDetailView.qml
        AddDeviceView.qml
        StatisticsView.qml
        HistoryView.qml
        AlertsView.qml
        ThresholdSettingsView.qml
        SettingsView.qml
        components/PageHeader.qml
        components/BottomNav.qml
        components/MetricCard.qml
        components/RoomCard.qml
        components/DeviceRow.qml
        components/SegmentedTabs.qml
        components/LineChart.qml
        components/BarChart.qml
)

target_link_libraries(SmartHomeNE
    PRIVATE Qt6::Quick Qt6::Qml
)

set_target_properties(SmartHomeNE PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
