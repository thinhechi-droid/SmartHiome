import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property var formatMoney: function(v) { return Math.round(v) + " đ" }
    property var navigateBack: null

    signal back()
    property int mode: 0
    property bool chartMode: true

    function goBack() {
        if (typeof root.navigateBack === "function")
            root.navigateBack()
        else
            root.back()
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 30
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 14

            PageHeader {
                title: "Lịch sử tiêu thụ"
                showBack: true
                onBackClicked: root.goBack()
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 14

                SegmentedTabs {
                    Layout.fillWidth: true
                    tabs: ["Điện năng (kWh)", "Tiền điện (đ)"]
                    currentIndex: root.mode
                    onChanged: function(index) { root.mode = index }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "‹"; flat: true; Layout.preferredWidth: 42 }
                    Text { text: "15/05/2024"; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; color: "#111827"; font.bold: true }
                    Button { text: "›"; flat: true; Layout.preferredWidth: 42 }
                }

                SegmentedTabs {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 210
                    tabs: ["Biểu đồ", "Bảng"]
                    currentIndex: root.chartMode ? 0 : 1
                    onChanged: function(index) { root.chartMode = index === 0 }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: root.chartMode ? 270 : 1
                    visible: root.chartMode
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    LineChart {
                        anchors.fill: parent
                        anchors.margins: 14
                        points: simulationEngine.historyLinePoints
                        showLabels: false
                        Connections { target: simulationEngine; function onDataChanged() { parent.requestPaint() } }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: tableCol.implicitHeight + 24
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: tableCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        spacing: 13

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Tổng tiêu thụ"; Layout.fillWidth: true; color: "#6b7280" }
                            ColumnLayout {
                                spacing: 2
                                Text { text: simulationEngine.todayKwh.toFixed(1) + " kWh"; color: "#111827"; font.bold: true; horizontalAlignment: Text.AlignRight; Layout.fillWidth: true }
                                Text { text: "≈ " + root.formatMoney(simulationEngine.todayCost); color: "#6b7280"; font.pixelSize: 12; horizontalAlignment: Text.AlignRight; Layout.fillWidth: true }
                            }
                        }

                        Repeater {
                            model: [
                                { time: "00:00 - 04:00", value: "2.1 kWh" },
                                { time: "04:00 - 08:00", value: "3.3 kWh" },
                                { time: "08:00 - 12:00", value: "4.8 kWh" },
                                { time: "12:00 - 16:00", value: "3.9 kWh" },
                                { time: "16:00 - 20:00", value: "3.1 kWh" },
                                { time: "20:00 - 24:00", value: "1.5 kWh" }
                            ]
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                Text { text: modelData.time; Layout.fillWidth: true; color: "#374151"; font.pixelSize: 13 }
                                Text { text: modelData.value; color: "#111827"; font.pixelSize: 13; font.bold: true }
                            }
                        }
                    }
                }
            }
        }
    }
}
