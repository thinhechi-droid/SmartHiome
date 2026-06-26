pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root

    property var settingsState: null
    property var navigateBack: null
    property string toastMessage: ""
    property bool toastVisible: false

    signal back()

    function formatNumber(value) {
        return Math.round(value).toLocaleString(Qt.locale("vi_VN"))
    }

    function setSetting(key, value) {
        if (!root.settingsState)
            return

        root.settingsState[key] = value
    }

    function showToast(message) {
        toastMessage = message
        toastVisible = true
        toastTimer.restart()
    }

    function goBack() {
        if (typeof root.navigateBack === "function")
            root.navigateBack()
        else
            root.back()
    }

    property var thresholdRows: [
        {
            key: "dailyThreshold",
            label: "Ngưỡng ngày",
            desc: "Cảnh báo khi tổng điện năng trong ngày vượt mức cho phép.",
            suffix: " kWh",
            from: 1,
            to: 100,
            step: 1,
            value: root.settingsState ? root.settingsState.dailyThreshold : 20
        },
        {
            key: "monthlyThreshold",
            label: "Ngưỡng tháng",
            desc: "Dùng để theo dõi tổng điện năng tiêu thụ trong tháng.",
            suffix: " kWh",
            from: 100,
            to: 2000,
            step: 10,
            value: root.settingsState ? root.settingsState.monthlyThreshold : 600
        },
        {
            key: "budgetThreshold",
            label: "Ngưỡng tiền điện",
            desc: "Cảnh báo khi chi phí tạm tính vượt ngân sách đã đặt.",
            suffix: " đ",
            from: 100000,
            to: 5000000,
            step: 50000,
            value: root.settingsState ? root.settingsState.budgetThreshold : 1500000
        }
    ]

    property var ruleRows: [
        {
            key: "acHours",
            label: "Điều hòa",
            desc: "Tự động nhắc tắt điều hòa khi chạy quá lâu.",
            suffix: " giờ",
            from: 1,
            to: 24,
            step: 1,
            value: root.settingsState ? root.settingsState.acHours : 8
        },
        {
            key: "heaterMinutes",
            label: "Bình nóng lạnh",
            desc: "Tự động nhắc tắt bình nóng lạnh sau thời gian sử dụng.",
            suffix: " phút",
            from: 15,
            to: 180,
            step: 5,
            value: root.settingsState ? root.settingsState.heaterMinutes : 60
        },
        {
            key: "lightHours",
            label: "Đèn",
            desc: "Tự động nhắc tắt đèn khi bật liên tục quá thời gian đặt.",
            suffix: " giờ",
            from: 1,
            to: 24,
            step: 1,
            value: root.settingsState ? root.settingsState.lightHours : 6
        }
    ]

    Timer {
        id: toastTimer
        interval: 1800
        onTriggered: root.toastVisible = false
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

            PageHeader {
                title: "Cài đặt ngưỡng"
                showBack: true
                onBackClicked: root.goBack()
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: thresholdCol.implicitHeight + 26
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: thresholdCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 14

                        Text {
                            text: "Ngưỡng tiêu thụ điện"
                            color: "#111827"
                            font.bold: true
                            font.pixelSize: 16
                        }

                        Text {
                            text: "Thiết lập mức cảnh báo để ứng dụng nhắc người dùng khi điện năng hoặc chi phí vượt giới hạn."
                            color: "#6b7280"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        Repeater {
                            model: root.thresholdRows

                            delegate: Rectangle {
                                id: thresholdRow

                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: thresholdItemCol.implicitHeight + 18
                                radius: 16
                                color: "#f8fbff"
                                border.width: 1
                                border.color: "#eef2f7"

                                ColumnLayout {
                                    id: thresholdItemCol
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: thresholdRow.modelData.label
                                            color: "#111827"
                                            font.bold: true
                                            font.pixelSize: 13
                                            Layout.fillWidth: true
                                        }

                                        SpinBox {
                                            from: thresholdRow.modelData.from
                                            to: thresholdRow.modelData.to
                                            stepSize: thresholdRow.modelData.step
                                            editable: true
                                            value: thresholdRow.modelData.value
                                            Layout.preferredWidth: 142
                                            onValueChanged: root.setSetting(thresholdRow.modelData.key, value)
                                            textFromValue: function(value, locale) {
                                                return root.formatNumber(value) + thresholdRow.modelData.suffix
                                            }
                                            valueFromText: function(text, locale) {
                                                return Number(text.replace(/[^0-9]/g, ""))
                                            }
                                        }
                                    }

                                    Text {
                                        text: thresholdRow.modelData.desc
                                        color: "#6b7280"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: ruleCol.implicitHeight + 26
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: ruleCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 14

                        Text {
                            text: "Quy tắc thiết bị"
                            color: "#111827"
                            font.bold: true
                            font.pixelSize: 16
                        }

                        Text {
                            text: "Cấu hình thời gian nhắc nhở hoặc tự động tắt đối với các thiết bị tiêu thụ nhiều điện."
                            color: "#6b7280"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Bật cảnh báo"
                                    color: "#111827"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: "Hiển thị cảnh báo khi vượt ngưỡng đã đặt."
                                    color: "#6b7280"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            Switch {
                                checked: root.settingsState ? root.settingsState.notificationsEnabled : true
                                onToggled: {
                                    if (root.settingsState)
                                        root.settingsState.notificationsEnabled = checked
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Tự động tắt thiết bị"
                                    color: "#111827"
                                    font.pixelSize: 13
                                    font.bold: true
                                }

                                Text {
                                    text: "Áp dụng quy tắc tắt thiết bị khi thời gian sử dụng vượt giới hạn."
                                    color: "#6b7280"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }

                            Switch {
                                checked: root.settingsState ? root.settingsState.autoTurnOffEnabled : true
                                onToggled: {
                                    if (root.settingsState)
                                        root.settingsState.autoTurnOffEnabled = checked
                                }
                            }
                        }

                        Repeater {
                            model: root.ruleRows

                            delegate: Rectangle {
                                id: ruleRow

                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: ruleItemCol.implicitHeight + 18
                                radius: 16
                                color: "#f8fbff"
                                border.width: 1
                                border.color: "#eef2f7"

                                ColumnLayout {
                                    id: ruleItemCol
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            text: ruleRow.modelData.label
                                            color: "#111827"
                                            font.bold: true
                                            font.pixelSize: 13
                                            Layout.fillWidth: true
                                        }

                                        SpinBox {
                                            from: ruleRow.modelData.from
                                            to: ruleRow.modelData.to
                                            stepSize: ruleRow.modelData.step
                                            editable: true
                                            value: ruleRow.modelData.value
                                            Layout.preferredWidth: 142
                                            onValueChanged: root.setSetting(ruleRow.modelData.key, value)
                                            textFromValue: function(value, locale) {
                                                return root.formatNumber(value) + ruleRow.modelData.suffix
                                            }
                                            valueFromText: function(text, locale) {
                                                return Number(text.replace(/[^0-9]/g, ""))
                                            }
                                        }
                                    }

                                    Text {
                                        text: ruleRow.modelData.desc
                                        color: "#6b7280"
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    text: "Lưu cài đặt"
                    font.bold: true
                    onClicked: root.showToast("Đã lưu cài đặt ngưỡng")
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
}
