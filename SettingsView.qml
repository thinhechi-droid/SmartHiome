pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root

    property var settingsState: null
    property string toastMessage: ""
    property bool toastVisible: false

    signal openThresholds()
    signal openHistory()
    signal openAlerts()
    signal logoutRequested()

    function money(v) {
        return Math.round(v).toLocaleString(Qt.locale("vi_VN")) + " đ"
    }

    function showToast(message) {
        toastMessage = message
        toastVisible = true
        toastTimer.restart()
    }

    function openAction(action) {
        if (action === "home") {
            homeDialog.open()
        } else if (action === "members") {
            membersDialog.open()
        } else if (action === "price") {
            priceDialog.open()
        } else if (action === "unit") {
            unitDialog.open()
        } else if (action === "thresholds") {
            root.openThresholds()
        } else if (action === "history") {
            root.openHistory()
        } else if (action === "alerts") {
            root.openAlerts()
        } else if (action === "backup") {
            backupDialog.open()
        } else if (action === "about") {
            aboutDialog.open()
        }
    }

    function addMember(name) {
        var value = name.trim()
        if (value.length === 0 || !root.settingsState)
            return

        var members = root.settingsState.memberNames.slice()
        members.push(value)
        root.settingsState.memberNames = members
        showToast("Đã thêm thành viên")
    }

    function removeMember(index) {
        if (!root.settingsState || index <= 0)
            return

        var members = root.settingsState.memberNames.slice()
        members.splice(index, 1)
        root.settingsState.memberNames = members
        showToast("Đã xóa thành viên")
    }

    Timer {
        id: toastTimer
        interval: 1800
        onTriggered: root.toastVisible = false
    }

    component SettingRow: Rectangle {
        id: row

        property string label: ""
        property string value: ""
        property string action: ""

        signal selected(string action)

        Layout.fillWidth: true
        Layout.preferredHeight: 54
        radius: 14
        color: rowMouse.pressed ? "#eaf3ff" : rowMouse.containsMouse ? "#f7fbff" : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: row.label
                Layout.fillWidth: true
                color: "#111827"
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            Text {
                text: row.value
                color: "#6b7280"
                font.pixelSize: 12
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
                Layout.maximumWidth: 150
            }

            Text {
                text: "›"
                color: "#9ca3af"
                font.pixelSize: 20
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.selected(row.action)
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 34
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 14

            PageHeader { title: "Cài đặt" }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 14

                        Rectangle {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            radius: 25
                            color: "#eaf3ff"

                            Text {
                                anchors.centerIn: parent
                                text: "⌂"
                                font.pixelSize: 30
                                color: "#1677ff"
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: root.settingsState ? root.settingsState.homeName : "Nhà của tôi"
                                color: "#111827"
                                font.bold: true
                                font.pixelSize: 16
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.settingsState ? root.settingsState.homeAddress : "Khu vực mô phỏng"
                                color: "#6b7280"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: settingsCol.implicitHeight + 16
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: settingsCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        spacing: 0

                        SettingRow {
                            label: "Quản lý nhà"
                            value: root.settingsState ? root.settingsState.homeName : "Nhà của tôi"
                            action: "home"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Quản lý thành viên"
                            value: root.settingsState ? root.settingsState.memberNames.length + " người" : ""
                            action: "members"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Giá điện"
                            value: root.settingsState ? root.money(root.settingsState.pricePerKwh) + "/kWh" : "2.436 đ/kWh"
                            action: "price"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Đơn vị tính"
                            value: root.settingsState ? root.settingsState.energyUnit + " - " + root.settingsState.currencyUnit : "kWh - đ"
                            action: "unit"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Cài đặt ngưỡng & quy tắc"
                            value: root.settingsState ? root.settingsState.dailyThreshold + " kWh/ngày" : ""
                            action: "thresholds"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Lịch sử tiêu thụ"
                            value: "Xem biểu đồ"
                            action: "history"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Cảnh báo"
                            value: "Theo dõi"
                            action: "alerts"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Sao lưu & khôi phục"
                            value: root.settingsState ? root.settingsState.lastBackup : ""
                            action: "backup"
                            onSelected: function(action) { root.openAction(action) }
                        }

                        SettingRow {
                            label: "Giới thiệu"
                            value: "Phiên bản 1.0"
                            action: "about"
                            onSelected: function(action) { root.openAction(action) }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    radius: 18
                    color: logoutMouse.pressed ? "#ffe1e1" : "#fff1f1"

                    Text {
                        anchors.centerIn: parent
                        text: "Đăng xuất"
                        color: "#ef4444"
                        font.bold: true
                    }

                    MouseArea {
                        id: logoutMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: logoutDialog.open()
                    }
                }
            }
        }
    }

    Rectangle {
        visible: root.toastVisible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        width: Math.min(parent.width - 48, toastText.implicitWidth + 34)
        height: 42
        radius: 21
        color: "#111827"
        opacity: 0.94
        z: 20

        Text {
            id: toastText
            anchors.centerIn: parent
            text: root.toastMessage
            color: "#ffffff"
            font.pixelSize: 12
        }
    }

    Dialog {
        id: homeDialog
        title: "Quản lý nhà"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Save | Dialog.Cancel
        onOpened: {
            homeNameField.text = root.settingsState ? root.settingsState.homeName : "Nhà của tôi"
            homeAddressField.text = root.settingsState ? root.settingsState.homeAddress : "Khu vực mô phỏng"
        }
        onAccepted: {
            if (root.settingsState) {
                root.settingsState.homeName = homeNameField.text.length > 0 ? homeNameField.text : "Nhà của tôi"
                root.settingsState.homeAddress = homeAddressField.text.length > 0 ? homeAddressField.text : "Khu vực mô phỏng"
            }
            root.showToast("Đã lưu thông tin nhà")
        }

        contentItem: ColumnLayout {
            spacing: 12

            Label { text: "Tên nhà"; color: "#374151" }
            TextField {
                id: homeNameField
                Layout.fillWidth: true
                placeholderText: "Nhập tên nhà"
            }

            Label { text: "Khu vực"; color: "#374151" }
            TextField {
                id: homeAddressField
                Layout.fillWidth: true
                placeholderText: "Nhập khu vực"
            }
        }
    }

    Dialog {
        id: membersDialog
        title: "Quản lý thành viên"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Close
        onOpened: memberField.text = ""

        contentItem: ColumnLayout {
            spacing: 12

            Repeater {
                model: root.settingsState ? root.settingsState.memberNames : []

                delegate: RowLayout {
                    id: memberRow

                    required property string modelData
                    required property int index

                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: "#eaf3ff"

                        Text {
                            anchors.centerIn: parent
                            text: memberRow.index + 1
                            color: "#1677ff"
                            font.bold: true
                        }
                    }

                    Label {
                        text: memberRow.modelData
                        Layout.fillWidth: true
                        color: "#111827"
                        elide: Text.ElideRight
                    }

                    Button {
                        visible: memberRow.index > 0
                        text: "Xóa"
                        onClicked: root.removeMember(memberRow.index)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: memberField
                    Layout.fillWidth: true
                    placeholderText: "Tên thành viên"
                    onAccepted: {
                        root.addMember(text)
                        text = ""
                    }
                }

                Button {
                    text: "Thêm"
                    onClicked: {
                        root.addMember(memberField.text)
                        memberField.text = ""
                    }
                }
            }
        }
    }

    Dialog {
        id: priceDialog
        title: "Giá điện"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Save | Dialog.Cancel
        onOpened: priceSpin.value = root.settingsState ? root.settingsState.pricePerKwh : Math.round(simulationEngine.pricePerKwh)
        onAccepted: {
            if (root.settingsState)
                root.settingsState.pricePerKwh = priceSpin.value
            simulationEngine.pricePerKwh = priceSpin.value
            root.showToast("Đã cập nhật giá điện")
        }

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                text: "Đơn giá tiền điện dùng để tính chi phí tạm tính."
                color: "#6b7280"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            SpinBox {
                id: priceSpin
                Layout.fillWidth: true
                from: 0
                to: 20000
                stepSize: 50
                editable: true
                textFromValue: function(value, locale) {
                    return Math.round(value).toLocaleString(Qt.locale("vi_VN")) + " đ/kWh"
                }
                valueFromText: function(text, locale) {
                    return Number(text.replace(/[^0-9]/g, ""))
                }
            }
        }
    }

    Dialog {
        id: unitDialog
        title: "Đơn vị tính"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Save | Dialog.Cancel
        onOpened: {
            energyUnit.currentIndex = root.settingsState && root.settingsState.energyUnit === "Wh" ? 1 : 0
            currencyUnit.currentIndex = root.settingsState && root.settingsState.currencyUnit === "VND" ? 1 : 0
        }
        onAccepted: {
            if (root.settingsState) {
                root.settingsState.energyUnit = energyUnit.currentText
                root.settingsState.currencyUnit = currencyUnit.currentText
            }
            root.showToast("Đã lưu đơn vị tính")
        }

        contentItem: ColumnLayout {
            spacing: 12

            Label { text: "Điện năng"; color: "#374151" }
            ComboBox {
                id: energyUnit
                Layout.fillWidth: true
                model: ["kWh", "Wh"]
            }

            Label { text: "Tiền tệ"; color: "#374151" }
            ComboBox {
                id: currencyUnit
                Layout.fillWidth: true
                model: ["đ", "VND"]
            }
        }
    }

    Dialog {
        id: backupDialog
        title: "Sao lưu & khôi phục"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Close

        contentItem: ColumnLayout {
            spacing: 12

            Label {
                text: root.settingsState ? "Lần sao lưu gần nhất: " + root.settingsState.lastBackup : ""
                color: "#6b7280"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                Layout.fillWidth: true
                text: "Tạo bản sao lưu"
                onClicked: {
                    if (root.settingsState)
                        root.settingsState.lastBackup = Qt.formatDateTime(new Date(), "dd/MM/yyyy HH:mm")
                    root.showToast("Đã tạo bản sao lưu mô phỏng")
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Quét lại thiết bị"
                onClicked: {
                    simulationEngine.rescanDevices()
                    root.showToast("Đã quét lại danh sách thiết bị")
                }
            }

            Button {
                Layout.fillWidth: true
                text: "Reset dữ liệu hôm nay"
                onClicked: {
                    simulationEngine.resetToday()
                    root.showToast("Đã reset dữ liệu hôm nay")
                }
            }
        }
    }

    Dialog {
        id: aboutDialog
        title: "Giới thiệu"
        modal: true
        width: Math.min(root.width - 36, 360)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Close

        contentItem: ColumnLayout {
            spacing: 10

            Label {
                text: "Ứng dụng Smart Home"
                color: "#111827"
                font.bold: true
                font.pixelSize: 16
            }

            Label {
                text: "Giám sát điện tiêu thụ và bật tắt từ xa các thiết bị điện trong gia đình."
                color: "#6b7280"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: "Phiên bản: 1.0\nNền tảng: Qt Quick/QML"
                color: "#6b7280"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

    Dialog {
        id: logoutDialog
        title: "Đăng xuất"
        modal: true
        width: Math.min(root.width - 36, 340)
        x: (root.width - width) / 2
        y: Math.max(24, (root.height - height) / 2)
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: root.logoutRequested()

        contentItem: Label {
            text: "Bạn có muốn đăng xuất khỏi ứng dụng không?"
            color: "#374151"
            wrapMode: Text.WordWrap
        }
    }
}
