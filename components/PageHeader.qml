import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: headerRoot

    property string title: ""
    property bool showBack: false
    property bool showAdd: false
    property bool showBell: false
    property bool showGear: false

    property var backAction: null
    property var addAction: null
    property var bellAction: null
    property var gearAction: null

    signal backClicked()
    signal addClicked()
    signal bellClicked()
    signal gearClicked()

    height: 64
    width: parent ? parent.width : 360

    function runAction(action) {
        if (typeof action === "function") {
            action()
        }
    }

    function triggerBack() {
        headerRoot.backClicked()
        if (typeof headerRoot.backAction === "function")
            headerRoot.runAction(headerRoot.backAction)
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 12

        Rectangle {
            visible: headerRoot.showBack
            Layout.preferredWidth: visible ? 48 : 0
            Layout.preferredHeight: 48
            radius: 16
            color: backMouse.pressed ? "#dbeafe" : backMouse.containsMouse ? "#eef6ff" : "transparent"
            z: 10

            Text {
                anchors.centerIn: parent
                text: "‹"
                color: "#0f172a"
                font.pixelSize: 32
                font.bold: true
            }

            MouseArea {
                id: backMouse
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: headerRoot.triggerBack()
            }
        }

        Text {
            text: headerRoot.title
            font.pixelSize: 20
            font.bold: true
            color: "#111827"
            elide: Text.ElideRight
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }

        ToolButton {
            visible: headerRoot.showAdd
            text: "+"
            font.pixelSize: 24
            Layout.preferredWidth: visible ? 38 : 0
            Layout.preferredHeight: 38
            onClicked: {
                headerRoot.addClicked()
                headerRoot.runAction(headerRoot.addAction)
            }
        }

        ToolButton {
            visible: headerRoot.showBell
            text: "🔔"
            font.pixelSize: 18
            Layout.preferredWidth: visible ? 38 : 0
            Layout.preferredHeight: 38
            onClicked: {
                headerRoot.bellClicked()
                headerRoot.runAction(headerRoot.bellAction)
            }
        }

        ToolButton {
            visible: headerRoot.showGear
            text: "⚙"
            font.pixelSize: 20
            Layout.preferredWidth: visible ? 38 : 0
            Layout.preferredHeight: 38
            onClicked: {
                headerRoot.gearClicked()
                headerRoot.runAction(headerRoot.gearAction)
            }
        }
    }
}
