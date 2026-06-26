import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property var formatMoney: function(v) { return Math.round(v) + " đ" }
    signal openRooms()
    signal openAddDevice()
    signal openStats()
    signal openAlerts()
    signal openRoom(string roomName)
    signal openDevice(string deviceName)

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 26
        clip: true

        ColumnLayout {
            id: contentCol
            width: parent.width
            spacing: 14

            PageHeader {
                title: "Nhà của tôi⌄"
                showBell: true
                onBellClicked: root.openAlerts()
            }

            Rectangle {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                height: 170
                radius: 24
                color: "#edf5ff"
                border.width: 1
                border.color: "#deebff"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 7
                        Text { text: "Tiêu thụ hôm nay"; color: "#4b5563"; font.pixelSize: 13 }
                        Text { text: simulationEngine.todayKwh.toFixed(1); color: "#111827"; font.pixelSize: 36; font.bold: true }
                        Text { text: "kWh"; color: "#111827"; font.pixelSize: 15; font.bold: true; anchors.leftMargin: 0 }
                        Text { text: "≈ " + root.formatMoney(simulationEngine.todayCost); color: "#374151"; font.pixelSize: 14; font.bold: true }
                        RowLayout {
                            Text { text: "So với hôm qua"; color: "#6b7280"; font.pixelSize: 12 }
                            Text { text: "▲ " + simulationEngine.compareYesterday.toFixed(0) + "%"; color: "#16a34a"; font.pixelSize: 12; font.bold: true }
                        }
                    }

                    Rectangle {
                        width: 82
                        height: 82
                        radius: 41
                        color: "transparent"
                        border.width: 4
                        border.color: "#cbdcff"
                        Text { anchors.centerIn: parent; text: "⚡"; color: "#1677ff"; font.pixelSize: 38 }
                    }
                }
            }

            RowLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 10

                MetricCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    title: "Thiết bị *nhà"
                    value: simulationEngine.activeDeviceCount + ""
                    subtitle: "đang bật"
                    accent: "#1677ff"
                    bg: "#f7fbff"
                }
                MetricCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    title: "Phòng"
                    value: simulationEngine.roomCount + ""
                    subtitle: "khu vực"
                    accent: "#111827"
                    bg: "#ffffff"
                }
                MetricCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    title: "Cảnh báo"
                    value: simulationEngine.alertCount + ""
                    subtitle: "cần xem"
                    accent: "#ef4444"
                    bg: "#fff1f1"
                    MouseArea { anchors.fill: parent; onClicked: root.openAlerts() }
                }
            }

            Rectangle {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                implicitHeight: roomColumn.implicitHeight + 28
                radius: 22
                color: "#ffffff"
                border.width: 1
                border.color: "#eef2f7"

                ColumnLayout {
                    id: roomColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 16
                    spacing: 10

                    Text { text: "Tiêu thụ theo phòng (hôm nay)"; font.bold: true; color: "#111827"; font.pixelSize: 14 }

                    Repeater {
                        model: simulationEngine.roomConsumption
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Text { text: modelData.name; Layout.preferredWidth: 86; color: "#111827"; font.pixelSize: 12 }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: "#eef2f7"
                                Rectangle {
                                    width: parent.width * modelData.percent / 42
                                    height: parent.height
                                    radius: 3
                                    color: "#1677ff"
                                }
                            }
                            Text { text: Number(modelData.kwh).toFixed(1) + " kWh"; Layout.preferredWidth: 50; color: "#374151"; font.pixelSize: 11 }
                            Text { text: modelData.percent + "%"; Layout.preferredWidth: 28; color: "#6b7280"; font.pixelSize: 11 }
                        }
                    }

                    Button {
                        text: "Xem chi tiết ›"
                        flat: true
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: root.openRooms()
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 12

                Text { text: "Thiết bị thường dùng"; font.bold: true; font.pixelSize: 15; color: "#111827" }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 4
                    rowSpacing: 12
                    columnSpacing: 8

                    Repeater {
                        model: [
                            { icon: "💡", name: "Đèn phòng\nkhách" },
                            { icon: "▭", name: "Điều hòa\nphòng ngủ" },
                            { icon: "🌀", name: "Quạt\nphòng khách" },
                            { icon: "▣", name: "Tivi\nphòng khách" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 86
                            radius: 18
                            color: "#ffffff"
                            border.width: 1
                            border.color: "#eef2f7"
                            Column {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: modelData.icon; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 25 }
                                Text { text: modelData.name; horizontalAlignment: Text.AlignHCenter; color: "#374151"; font.pixelSize: 11 }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.openDevice(modelData.name.replace("\n", " ")) }
                        }
                    }
                }
            }
        }
    }
}
