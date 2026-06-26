import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var tabs: ["Ngày", "Tuần", "Tháng", "Năm"]
    property int currentIndex: 0
    signal changed(int index)

    height: 40
    radius: 20
    color: "#f2f5fa"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: root.tabs
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: index === root.currentIndex ? "#1677ff" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: index === root.currentIndex ? "#ffffff" : "#6b7280"
                    font.bold: index === root.currentIndex
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.currentIndex = index
                        root.changed(index)
                    }
                }
            }
        }
    }
}
