import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string name: "Phòng"
    property string icon: "⌂"
    property int deviceCount: 0
    property real kwh: 0
    signal clicked()

    height: 98
    radius: 18
    color: "#ffffff"
    border.width: 1
    border.color: "#edf1f7"

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Rectangle {
            width: 46
            height: 46
            radius: 14
            color: "#edf7ff"
            Text { anchors.centerIn: parent; text: root.icon; font.pixelSize: 23 }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text { text: root.name; color: "#111827"; font.bold: true; font.pixelSize: 15 }
            Text { text: root.deviceCount + " thiết bị"; color: "#6b7280"; font.pixelSize: 12 }
        }

        Text {
            text: root.kwh.toFixed(1) + " kWh"
            color: "#111827"
            font.pixelSize: 12
        }
    }

    MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
