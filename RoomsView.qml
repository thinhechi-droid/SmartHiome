import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    signal openRoom(string roomName)
    signal openAddDevice()

    property var extraDevices: []

    function extraCount(roomName) {
        var count = 0
        for (var i = 0; i < extraDevices.length; i++) {
            if (extraDevices[i].room === roomName)
                count++
        }
        return count
    }

    function extraKwh(roomName) {
        // Mô phỏng nhanh: mỗi thiết bị thêm vào đóng góp một lượng điện nhỏ để số liệu phòng có thay đổi.
        return extraCount(roomName) * 0.3
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 26
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 16

            PageHeader {
                title: "Phòng"
                showAdd: true
                onAddClicked: root.openAddDevice()
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 14

                Repeater {
                    model: [
                        { name: "Phòng khách", icon: "🛋️", count: 5, kwh: 7.2 },
                        { name: "Phòng ngủ", icon: "🛏️", count: 3, kwh: 4.1 },
                        { name: "Bếp", icon: "🍳", count: 4, kwh: 3.6 },
                        { name: "Phòng giặt", icon: "🧺", count: 2, kwh: 2.2 },
                        { name: "Phòng tắm", icon: "🛁", count: 2, kwh: 1.6 }
                    ]
                    delegate: RoomCard {
                        Layout.fillWidth: true
                        name: modelData.name
                        icon: modelData.icon
                        deviceCount: modelData.count + root.extraCount(modelData.name)
                        kwh: modelData.kwh + root.extraKwh(modelData.name)
                        onClicked: root.openRoom(modelData.name)
                    }
                }
            }
        }
    }
}
