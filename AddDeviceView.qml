import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property var navigateBack: null

    signal back()
    signal deviceAdded(var device)

    property bool showManualForm: false
    property bool scanRunning: true
    property int scanSecond: 0
    property int scanTick: 0

    property var foundDevices: [
        { icon: "▭", type: "Điều hòa", name: "Điều hòa Panasonic", power: "900 W" },
        { icon: "▣", type: "Tivi", name: "Tivi Samsung", power: "120 W" },
        { icon: "🌀", type: "Quạt", name: "Quạt Mitsubishi", power: "45 W" },
        { icon: "💡", type: "Đèn", name: "Đèn Philips Hue", power: "10 W" }
    ]

    function restartScan() {
        scanRunning = true
        scanSecond = 0
        scanTick = 0
        showManualForm = false
    }

    function goBack() {
        if (typeof root.navigateBack === "function")
            root.navigateBack()
        else
            root.back()
    }

    Timer {
        interval: 800
        running: root.scanRunning
        repeat: true
        onTriggered: {
            scanTick++
            root.scanSecond++
            if (root.scanSecond >= 5) {
                root.scanRunning = false
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 30
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 14

            PageHeader {
                title: "Thêm thiết bị"
                showBack: true
                onBackClicked: root.goBack()
            }

            Item {
                Layout.fillWidth: true
                height: 170

                Rectangle {
                    width: 132 + Math.sin(root.scanTick) * 4
                    height: width
                    radius: width / 2
                    anchors.centerIn: parent
                    color: root.scanRunning ? "#eaf3ff" : "#ecfdf5"
                    opacity: 0.95
                }
                Rectangle {
                    width: 86
                    height: 86
                    radius: 43
                    anchors.centerIn: parent
                    color: root.scanRunning ? "#d7e9ff" : "#d1fae5"
                    opacity: 0.9
                }
                Rectangle {
                    width: 48
                    height: 48
                    radius: 24
                    anchors.centerIn: parent
                    color: root.scanRunning ? "#1677ff" : "#10b981"
                    Text {
                        anchors.centerIn: parent
                        text: root.scanRunning ? "●" : "✓"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }
                }
                Rectangle {
                    visible: root.scanRunning
                    width: 10
                    height: 10
                    radius: 5
                    x: parent.width / 2 + Math.cos(root.scanTick * 0.8) * 70
                    y: parent.height / 2 + Math.sin(root.scanTick * 0.8) * 58
                    color: "#1677ff"
                }
            }

            ColumnLayout {
                Layout.leftMargin: 22
                Layout.rightMargin: 22
                Layout.fillWidth: true
                spacing: 6
                Text {
                    text: root.scanRunning ? "Đang tìm kiếm thiết bị..." : "Đã tìm thấy " + root.foundDevices.length + " thiết bị"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pixelSize: 16
                    color: "#111827"
                }
                Text {
                    text: root.scanRunning ? "Đảm bảo thiết bị của bạn đang ở chế độ kết nối" : "Chọn phòng rồi bấm Thêm để đưa thiết bị vào danh sách phòng"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 12
                    color: "#6b7280"
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Thiết bị tìm thấy"; font.bold: true; color: "#111827"; font.pixelSize: 14; Layout.fillWidth: true }
                    Text {
                        text: root.scanRunning ? "Đang quét" : "Hoàn tất"
                        color: root.scanRunning ? "#1677ff" : "#10b981"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    radius: 16
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        Text { text: "Thêm vào phòng"; color: "#374151"; font.pixelSize: 13; Layout.fillWidth: true }
                        ComboBox {
                            id: targetRoomBox
                            Layout.preferredWidth: 165
                            model: ["Phòng khách", "Phòng ngủ", "Bếp", "Phòng giặt", "Phòng tắm"]
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: foundCol.implicitHeight + 16
                    radius: 18
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: foundCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 0

                        Text {
                            visible: root.scanRunning
                            Layout.fillWidth: true
                            height: 72
                            text: "Đang quét, vui lòng chờ vài giây..."
                            color: "#6b7280"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 13
                        }

                        Repeater {
                            model: root.scanRunning ? [] : root.foundDevices
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 62
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 12
                                    Text { text: modelData.icon; font.pixelSize: 22; Layout.preferredWidth: 30 }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text { text: modelData.name; color: "#111827"; font.bold: true; font.pixelSize: 13 }
                                        Text { text: modelData.type + " • " + modelData.power; color: "#6b7280"; font.pixelSize: 11 }
                                    }
                                    Button {
                                        text: "Thêm"
                                        Layout.preferredWidth: 76
                                        onClicked: {
                                            root.deviceAdded({
                                                room: targetRoomBox.currentText,
                                                icon: modelData.icon,
                                                type: modelData.type,
                                                name: modelData.name,
                                                power: modelData.power
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    height: 48
                    text: root.scanRunning ? "Đang quét..." : "Quét lại"
                    enabled: !root.scanRunning
                    onClicked: {
                        simulationEngine.rescanDevices()
                        root.restartScan()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: manualCol.implicitHeight + 22
                    radius: 20
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: manualCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Không tìm thấy thiết bị mong muốn?"
                                Layout.fillWidth: true
                                color: "#111827"
                                font.bold: true
                                font.pixelSize: 14
                            }
                            Button {
                                text: root.showManualForm ? "Ẩn" : "Nhập thủ công"
                                flat: true
                                onClicked: root.showManualForm = !root.showManualForm
                            }
                        }

                        Text {
                            visible: !root.showManualForm
                            text: "Phần nhập thủ công được đặt ở cuối trang quét và chỉ mở khi bạn cần."
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#6b7280"
                            font.pixelSize: 12
                        }

                        ColumnLayout {
                            visible: root.showManualForm
                            Layout.fillWidth: true
                            spacing: 10

                            TextField { id: deviceName; Layout.fillWidth: true; placeholderText: "Tên thiết bị" }
                            ComboBox { id: roomBox; Layout.fillWidth: true; model: ["Phòng khách", "Phòng ngủ", "Bếp", "Phòng giặt", "Phòng tắm"] }
                            ComboBox { id: typeBox; Layout.fillWidth: true; model: ["Đèn", "Điều hòa", "Quạt", "Tivi", "Tủ lạnh", "Khác"] }
                            TextField { id: powerField; Layout.fillWidth: true; placeholderText: "Công suất tiêu thụ (W)"; inputMethodHints: Qt.ImhDigitsOnly }

                            Button {
                                Layout.fillWidth: true
                                height: 48
                                text: "Thêm thiết bị thủ công"
                                onClicked: {
                                    if (deviceName.text.trim().length === 0)
                                        return

                                    var p = powerField.text.trim().length > 0 ? powerField.text.trim() + " W" : "0 W"
                                    root.deviceAdded({
                                        room: roomBox.currentText,
                                        type: typeBox.currentText,
                                        name: deviceName.text.trim(),
                                        power: p
                                    })

                                    deviceName.text = ""
                                    powerField.text = ""
                                    root.showManualForm = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
