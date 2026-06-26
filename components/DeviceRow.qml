import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string name: "Thiết bị"
    property string icon: "▣"
    property string detail: "0 W"
    property bool checked: true
    property bool showSlider: false
    property string sliderLabel: ""
    property real sliderValue: 70
    property string room: ""
    signal clicked()

    height: showSlider ? 108 : 72
    radius: 16
    color: "#ffffff"
    border.width: 1
    border.color: "#edf1f7"

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 12
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text { text: root.icon; font.pixelSize: 22; Layout.preferredWidth: 28 }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: root.name; font.bold: true; color: "#111827"; font.pixelSize: 14 }
                Text { text: root.detail; color: "#6b7280"; font.pixelSize: 11 }
            }
            Switch { checked: root.checked }
        }

        RowLayout {
            visible: root.showSlider
            Layout.fillWidth: true
            Text { text: root.sliderLabel; color: "#6b7280"; font.pixelSize: 12; Layout.preferredWidth: 76 }
            Slider { value: root.sliderValue / 100; Layout.fillWidth: true }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 60
        onClicked: root.clicked()
    }
}
