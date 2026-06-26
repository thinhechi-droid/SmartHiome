import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property var navigateBack: null

    signal back()
    property int tabIndex: 0

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
                title: "Cảnh báo"
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
                    tabs: ["Tất cả", "Thiết bị", "Hệ thống"]
                    currentIndex: root.tabIndex
                    onChanged: function(index) { root.tabIndex = index }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: alertCol.implicitHeight + 18
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: alertCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 2

                        Repeater {
                            model: simulationEngine.alerts
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 76
                                radius: 16
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 8
                                    spacing: 12

                                    Rectangle {
                                        width: 34
                                        height: 34
                                        radius: 17
                                        color: modelData.type === "danger" ? "#fff1f1" : modelData.type === "warning" ? "#fff7e6" : "#eaf3ff"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.type === "danger" ? "⚠" : modelData.type === "warning" ? "△" : "ⓘ"
                                            color: modelData.type === "danger" ? "#ef4444" : modelData.type === "warning" ? "#f59e0b" : "#1677ff"
                                            font.pixelSize: 17
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text { text: modelData.title; color: "#111827"; font.bold: true; font.pixelSize: 13; elide: Text.ElideRight; Layout.fillWidth: true }
                                        Text { text: modelData.desc; color: "#6b7280"; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }

                                    Text { text: modelData.time; color: "#6b7280"; font.pixelSize: 12; Layout.alignment: Qt.AlignTop }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
