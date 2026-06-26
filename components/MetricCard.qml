import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property string title: ""
    property string value: ""
    property string subtitle: ""
    property string accent: "#1677ff"
    property string bg: "#ffffff"

    radius: 18
    color: bg
    border.width: 1
    border.color: "#eef2f7"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        Text { text: root.title; color: "#6b7280"; font.pixelSize: 12; Layout.fillWidth: true }
        Text { text: root.value; color: root.accent; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
        Text { text: root.subtitle; color: "#6b7280"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
    }
}
