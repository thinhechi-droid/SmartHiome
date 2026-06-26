import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string current: "home"
    signal selected(string page)

    width: parent ? parent.width : 360
    height: 76
    color: "#ffffff"
    radius: 26

    border.width: 1
    border.color: "#eef2f7"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 0

        Repeater {
            model: [
                { key: "home", icon: "⌂", label: "Trang chủ" },
                { key: "add", icon: "▣", label: "Thiết bị" },
                { key: "rooms", icon: "⌘", label: "Phòng" },
                { key: "stats", icon: "▥", label: "Thống kê" },
                { key: "settings", icon: "⚙", label: "Cài đặt" }
            ]

            delegate: Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Text {
                        text: modelData.icon
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 21
                        color: root.current === modelData.key ? "#1677ff" : "#6b7280"
                    }

                    Text {
                        text: modelData.label
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 10
                        font.bold: root.current === modelData.key
                        color: root.current === modelData.key ? "#1677ff" : "#6b7280"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.selected(modelData.key)
                }
            }
        }
    }
}
