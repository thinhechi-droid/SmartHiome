import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string pageMode: "devices"        // devices | scan
    property string selectedRoom: "Tất cả"
    property string searchText: ""
    property bool showManualAddForm: false
    property bool scanning: false
    property int scanStep: 0
    property int refreshKey: 0

    function normalized(value) {
        return String(value || "").toLowerCase().trim()
    }

    function deviceIcon(type) {
        if (type === "Đèn") return "💡"
        if (type === "Quạt") return "🌀"
        if (type === "Điều hòa") return "❄️"
        if (type === "TV") return "📺"
        if (type === "Cảm biến") return "📟"
        if (type === "Máy giặt") return "🧺"
        if (type === "Rèm cửa") return "🪟"
        if (type === "Ổ cắm") return "🔌"
        if (type === "Camera") return "📷"
        return "⚙️"
    }

    function roomExists(room) {
        for (var i = 0; i < roomModel.count; i++) {
            if (roomModel.get(i).roomName === room) return true
        }
        return false
    }

    function ensureRoom(room) {
        if (!room || room.trim() === "") room = "Chưa phân loại"
        if (!roomExists(room)) roomModel.append({ roomName: room })
        return room
    }

    function roomCount(room) {
        refreshKey
        var count = 0
        for (var i = 0; i < deviceModel.count; i++) {
            var d = deviceModel.get(i)
            if (room === "Tất cả" || d.roomName === room) count++
        }
        return count
    }

    function activePowerByRoom(room) {
        refreshKey
        var total = 0
        for (var i = 0; i < deviceModel.count; i++) {
            var d = deviceModel.get(i)
            if ((room === "Tất cả" || d.roomName === room) && d.isOn) {
                total += Number(d.powerW)
            }
        }
        return total
    }

    function matchesDevice(name, type, room) {
        var key = normalized(searchText)
        var roomOk = selectedRoom === "Tất cả" || room === selectedRoom
        var searchOk = key === "" || normalized(name).indexOf(key) >= 0
                     || normalized(type).indexOf(key) >= 0
                     || normalized(room).indexOf(key) >= 0
        return roomOk && searchOk
    }

    function filteredDeviceCount() {
        refreshKey
        var count = 0
        for (var i = 0; i < deviceModel.count; i++) {
            var d = deviceModel.get(i)
            if (matchesDevice(d.deviceName, d.deviceType, d.roomName)) count++
        }
        return count
    }

    function addDevice(name, type, power, room) {
        var safeName = String(name || "").trim()
        if (safeName === "") return false

        var safeType = String(type || "Khác")
        var safeRoom = ensureRoom(String(room || "Chưa phân loại").trim())
        var safePower = Number(power)
        if (isNaN(safePower) || safePower < 0) safePower = 0

        deviceModel.append({
            deviceName: safeName,
            deviceType: safeType,
            roomName: safeRoom,
            powerW: safePower,
            isOn: false
        })

        selectedRoom = safeRoom
        searchText = ""
        refreshKey++
        return true
    }

    function addScannedDevice(index) {
        if (index < 0 || index >= scannedDeviceModel.count) return
        var d = scannedDeviceModel.get(index)
        if (addDevice(d.deviceName, d.deviceType, d.powerW, d.roomName)) {
            scannedDeviceModel.remove(index)
            pageMode = "devices"
        }
    }

    function startScan() {
        pageMode = "scan"
        showManualAddForm = false
        scannedDeviceModel.clear()
        scanStep = 0
        scanning = true
        scanTimer.restart()
    }

    function restartScan() {
        showManualAddForm = false
        scannedDeviceModel.clear()
        scanStep = 0
        scanning = true
        scanTimer.restart()
    }

    ListModel {
        id: roomModel
        ListElement { roomName: "Tất cả" }
        ListElement { roomName: "Phòng khách" }
        ListElement { roomName: "Phòng ngủ" }
        ListElement { roomName: "Bếp" }
        ListElement { roomName: "Phòng giặt" }
        ListElement { roomName: "Phòng tắm" }
    }

    ListModel {
        id: deviceModel
        ListElement { deviceName: "Đèn trần"; deviceType: "Đèn"; roomName: "Phòng khách"; powerW: 10; isOn: true }
        ListElement { deviceName: "Quạt đứng"; deviceType: "Quạt"; roomName: "Phòng khách"; powerW: 45; isOn: true }
        ListElement { deviceName: "Tivi Samsung"; deviceType: "TV"; roomName: "Phòng khách"; powerW: 120; isOn: true }
        ListElement { deviceName: "Điều hòa phòng ngủ"; deviceType: "Điều hòa"; roomName: "Phòng ngủ"; powerW: 900; isOn: true }
        ListElement { deviceName: "Máy giặt"; deviceType: "Máy giặt"; roomName: "Phòng giặt"; powerW: 500; isOn: false }
        ListElement { deviceName: "Rèm cửa"; deviceType: "Rèm cửa"; roomName: "Phòng khách"; powerW: 30; isOn: false }
    }

    ListModel { id: scannedDeviceModel }

    Timer {
        id: scanTimer
        interval: 700
        repeat: true
        onTriggered: {
            var results = [
                { deviceName: "Điều hòa Panasonic", deviceType: "Điều hòa", roomName: "Phòng ngủ", powerW: 900, signal: "Mạnh" },
                { deviceName: "Tivi Samsung", deviceType: "TV", roomName: "Phòng khách", powerW: 120, signal: "Mạnh" },
                { deviceName: "Quạt Mitsubishi", deviceType: "Quạt", roomName: "Phòng khách", powerW: 45, signal: "Trung bình" },
                { deviceName: "Cảm biến cửa Zigbee", deviceType: "Cảm biến", roomName: "Phòng khách", powerW: 5, signal: "Trung bình" }
            ]

            if (scanStep < results.length) {
                scannedDeviceModel.append(results[scanStep])
                scanStep++
            } else {
                scanning = false
                scanTimer.stop()
            }
        }
    }

    Loader {
        anchors.fill: parent
        sourceComponent: pageMode === "scan" ? scanPage : devicePage
    }

    Component {
        id: devicePage

        Rectangle {
            color: "#f3f6fb"

            ScrollView {
                id: deviceScroll
                anchors.fill: parent
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: deviceScroll.availableWidth - 48
                    x: 24
                    y: 24
                    spacing: 18

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Thiết bị"
                                font.pixelSize: 30
                                font.bold: true
                                color: "#172033"
                            }

                            Text {
                                text: "Quản lý phòng, tìm kiếm thiết bị và quét thiết bị mô phỏng"
                                color: "#6b7280"
                                font.pixelSize: 14
                            }
                        }

                        Button {
                            text: "+ Quét thiết bị"
                            font.bold: true
                            onClicked: root.startScan()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
                        radius: 22
                        color: "#ffffff"
                        border.color: "#e5e7eb"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Rectangle {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 52
                                radius: 16
                                color: "#eaf2ff"

                                Text {
                                    anchors.centerIn: parent
                                    text: "🔎"
                                    font.pixelSize: 24
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: "Tìm kiếm thiết bị"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#172033"
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    placeholderText: "Nhập tên thiết bị, loại thiết bị hoặc tên phòng..."
                                    text: root.searchText
                                    selectByMouse: true
                                    onTextChanged: root.searchText = text
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Danh sách phòng"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#172033"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: roomCount("Tất cả") + " thiết bị"
                                color: "#6b7280"
                                font.pixelSize: 13
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 122
                            contentWidth: roomRow.implicitWidth
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            RowLayout {
                                id: roomRow
                                spacing: 12

                                Repeater {
                                    model: roomModel

                                    Rectangle {
                                        property bool active: root.selectedRoom === roomName
                                        Layout.preferredWidth: 172
                                        Layout.preferredHeight: 110
                                        radius: 22
                                        color: active ? "#eaf2ff" : "#ffffff"
                                        border.color: active ? "#2f80ed" : "#e5e7eb"
                                        border.width: active ? 2 : 1

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.selectedRoom = roomName
                                        }

                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 14
                                            spacing: 5

                                            Text {
                                                text: roomName === "Tất cả" ? "🏠" : "🚪"
                                                font.pixelSize: 22
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: roomName
                                                color: "#172033"
                                                font.bold: true
                                                font.pixelSize: 15
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: roomCount(roomName) + " thiết bị · " + activePowerByRoom(roomName) + " W"
                                                color: "#6b7280"
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: selectedRoom === "Tất cả" ? "Danh sách thiết bị" : "Thiết bị trong " + selectedRoom
                            font.pixelSize: 20
                            font.bold: true
                            color: "#172033"
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: filteredDeviceCount() + " kết quả"
                            color: "#6b7280"
                            font.pixelSize: 13
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: filteredDeviceCount() === 0
                        text: "Không tìm thấy thiết bị phù hợp. Bạn có thể bấm '+ Quét thiết bị' hoặc nhập thủ công ở cuối trang quét."
                        color: "#777"
                        font.pixelSize: 15
                        wrapMode: Text.WordWrap
                    }

                    Repeater {
                        model: deviceModel

                        Rectangle {
                            property bool matched: root.matchesDevice(deviceName, deviceType, roomName)
                            Layout.fillWidth: true
                            Layout.preferredHeight: matched ? 92 : 0
                            visible: matched
                            radius: 22
                            color: "#ffffff"
                            border.color: "#e5e7eb"
                            clip: true

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 14

                                Rectangle {
                                    Layout.preferredWidth: 54
                                    Layout.preferredHeight: 54
                                    radius: 17
                                    color: isOn ? "#eafaf1" : "#f3f4f6"

                                    Text {
                                        anchors.centerIn: parent
                                        text: deviceIcon(deviceType)
                                        font.pixelSize: 24
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Text {
                                        Layout.fillWidth: true
                                        text: deviceName
                                        color: "#172033"
                                        font.pixelSize: 16
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: roomName + " · " + deviceType + " · " + powerW + " W"
                                        color: "#6b7280"
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    text: isOn ? "Đang bật" : "Đang tắt"
                                    color: isOn ? "#16a34a" : "#9ca3af"
                                    font.pixelSize: 13
                                }

                                Switch {
                                    checked: isOn
                                    onToggled: {
                                        deviceModel.setProperty(index, "isOn", checked)
                                        root.refreshKey++
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 32 }
                }
            }
        }
    }

    Component {
        id: scanPage

        Rectangle {
            color: "#f3f6fb"

            ScrollView {
                id: scanScroll
                anchors.fill: parent
                contentWidth: availableWidth
                clip: true

                ColumnLayout {
                    width: Math.min(scanScroll.availableWidth - 48, 760)
                    x: Math.max(24, (scanScroll.availableWidth - width) / 2)
                    y: 24
                    spacing: 18

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ToolButton {
                            text: "‹"
                            font.pixelSize: 30
                            onClicked: {
                                scanTimer.stop()
                                scanning = false
                                pageMode = "devices"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: "Thêm thiết bị"
                                font.pixelSize: 30
                                font.bold: true
                                color: "#172033"
                            }

                            Text {
                                text: "Quét thiết bị mô phỏng trước. Nếu không có thiết bị mong muốn, nhập thủ công ở cuối trang."
                                color: "#6b7280"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 260
                        radius: 28
                        color: "#ffffff"
                        border.color: "#e5e7eb"
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Item {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 150
                                Layout.preferredHeight: 150

                                Rectangle {
                                    id: radarOuter
                                    anchors.centerIn: parent
                                    width: 138
                                    height: 138
                                    radius: 69
                                    color: "#eaf2ff"
                                    opacity: 0.6
                                    scale: scanning ? 1.0 : 0.92

                                    SequentialAnimation on scale {
                                        running: scanning
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.14; duration: 700; easing.type: Easing.InOutQuad }
                                        NumberAnimation { to: 0.92; duration: 700; easing.type: Easing.InOutQuad }
                                    }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 92
                                    height: 92
                                    radius: 46
                                    color: "#dbeafe"
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 48
                                    height: 48
                                    radius: 24
                                    color: "#2f80ed"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📡"
                                        font.pixelSize: 22
                                    }
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: scanning ? "Đang tìm kiếm thiết bị..." : "Hoàn tất quét thiết bị"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#172033"
                                font.pixelSize: 18
                                font.bold: true
                            }

                            Text {
                                Layout.fillWidth: true
                                text: scanning ? "Đảm bảo thiết bị đang bật và ở chế độ kết nối" : "Chọn thiết bị tìm thấy để thêm vào danh sách quản lý"
                                horizontalAlignment: Text.AlignHCenter
                                color: "#6b7280"
                                font.pixelSize: 13
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 26
                        color: "#ffffff"
                        border.color: "#e5e7eb"
                        implicitHeight: foundColumn.implicitHeight + 34

                        ColumnLayout {
                            id: foundColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 17
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Thiết bị tìm thấy"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#172033"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: scannedDeviceModel.count + " thiết bị"
                                    color: "#6b7280"
                                    font.pixelSize: 13
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: scannedDeviceModel.count === 0
                                text: scanning ? "Đang dò tìm thiết bị xung quanh..." : "Chưa tìm thấy thiết bị nào. Hãy quét lại hoặc nhập thủ công ở cuối trang."
                                color: "#777"
                                font.pixelSize: 15
                                wrapMode: Text.WordWrap
                            }

                            Repeater {
                                model: scannedDeviceModel

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 82
                                    radius: 20
                                    color: "#f9fafb"
                                    border.color: "#eef0f3"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 12

                                        Rectangle {
                                            Layout.preferredWidth: 50
                                            Layout.preferredHeight: 50
                                            radius: 16
                                            color: "#eaf2ff"

                                            Text {
                                                anchors.centerIn: parent
                                                text: deviceIcon(deviceType)
                                                font.pixelSize: 23
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 3

                                            Text {
                                                Layout.fillWidth: true
                                                text: deviceName
                                                color: "#172033"
                                                font.pixelSize: 16
                                                font.bold: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: roomName + " · " + powerW + " W · Tín hiệu: " + signal
                                                color: "#6b7280"
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Button {
                                            text: "Thêm"
                                            onClicked: root.addScannedDevice(index)
                                        }
                                    }
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: scanning ? "Đang quét..." : "Quét lại"
                                enabled: !scanning
                                onClicked: root.restartScan()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 26
                        color: "#ffffff"
                        border.color: "#e5e7eb"
                        implicitHeight: manualColumn.implicitHeight + 34

                        ColumnLayout {
                            id: manualColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 17
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3
                                    Text {
                                        text: "Không thấy thiết bị mong muốn?"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "#172033"
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Phần nhập thủ công được đặt ở cuối trang quét, chỉ mở khi cần."
                                        color: "#6b7280"
                                        font.pixelSize: 13
                                        wrapMode: Text.WordWrap
                                    }
                                }

                                Button {
                                    text: showManualAddForm ? "Ẩn" : "Nhập thủ công"
                                    onClicked: showManualAddForm = !showManualAddForm
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                visible: showManualAddForm

                                TextField {
                                    id: manualDeviceName
                                    Layout.fillWidth: true
                                    placeholderText: "Tên thiết bị, ví dụ: Đèn bàn học"
                                    selectByMouse: true
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    ComboBox {
                                        id: manualDeviceType
                                        Layout.fillWidth: true
                                        model: ["Đèn", "Quạt", "Điều hòa", "TV", "Cảm biến", "Máy giặt", "Rèm cửa", "Ổ cắm", "Camera", "Khác"]
                                    }

                                    TextField {
                                        id: manualDevicePower
                                        Layout.preferredWidth: 170
                                        placeholderText: "Công suất W"
                                        inputMethodHints: Qt.ImhDigitsOnly
                                        selectByMouse: true
                                    }
                                }

                                ComboBox {
                                    id: manualRoom
                                    Layout.fillWidth: true
                                    editable: true
                                    model: ["Phòng khách", "Phòng ngủ", "Bếp", "Phòng giặt", "Phòng tắm", "Phòng làm việc", "Chưa phân loại"]
                                    currentIndex: 0
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: "Thêm thiết bị thủ công"
                                    highlighted: true
                                    onClicked: {
                                        var ok = root.addDevice(manualDeviceName.text,
                                                                manualDeviceType.currentText,
                                                                manualDevicePower.text,
                                                                manualRoom.editText || manualRoom.currentText)
                                        if (ok) {
                                            manualDeviceName.text = ""
                                            manualDevicePower.text = ""
                                            showManualAddForm = false
                                            pageMode = "devices"
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 32 }
                }
            }
        }
    }
}
