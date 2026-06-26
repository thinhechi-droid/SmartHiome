import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property string deviceName: "Điều hòa phòng ngủ"
    property var navigateBack: null

    signal back()

    property int temperature: 24
    property int modeIndex: 0
    property int fanIndex: 2
    property int simpleLevel: 70
    property bool deviceOn: true

    readonly property string lowerName: deviceName.toLowerCase()
    readonly property bool isAirConditioner: lowerName.indexOf("điều hòa") >= 0 || lowerName.indexOf("dieu hoa") >= 0 || lowerName.indexOf("máy lạnh") >= 0 || lowerName.indexOf("may lanh") >= 0
    readonly property bool isLight: lowerName.indexOf("đèn") >= 0 || lowerName.indexOf("den") >= 0
    readonly property bool isFan: lowerName.indexOf("quạt") >= 0 || lowerName.indexOf("quat") >= 0
    readonly property bool isTv: lowerName.indexOf("tivi") >= 0 || lowerName.indexOf("tv") >= 0

    function simpleIcon() {
        if (isLight) return "💡"
        if (isFan) return "🌀"
        if (isTv) return "▣"
        return "▣"
    }

    function simpleTitle() {
        if (isLight) return "Mức sáng"
        if (isFan) return "Tốc độ quạt"
        if (isTv) return "Mức hoạt động"
        return "Mức hoạt động"
    }

    function simpleHint() {
        if (isLight) return "Điều chỉnh độ sáng của đèn."
        if (isFan) return "Điều chỉnh tốc độ quạt."
        if (isTv) return "Điều khiển nhanh trạng thái thiết bị."
        return "Điều khiển nhanh thiết bị."
    }

    function goBack() {
        if (typeof root.navigateBack === "function")
            root.navigateBack()
        else
            root.back()
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 30
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 14

            PageHeader {
                title: root.deviceName
                showBack: true
                showGear: true
                onBackClicked: root.goBack()
            }

            Loader {
                Layout.fillWidth: true
                sourceComponent: root.isAirConditioner ? airConditionerDetail : simpleDeviceDetail
            }
        }
    }

    Component {
        id: airConditionerDetail

        ColumnLayout {
            width: root.width
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: root.width - 52
                height: 128
                radius: 20
                color: "#ffffff"
                border.width: 1
                border.color: "#eef2f7"

                Rectangle {
                    width: 250
                    height: 74
                    radius: 12
                    color: "#f8fafc"
                    anchors.centerIn: parent
                    border.width: 1
                    border.color: "#e5e7eb"
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 22; width: 28; height: 4; radius: 2; color: "#6b7280" }
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 46; width: 190; height: 7; radius: 4; color: "#1f2937" }
                    Rectangle { x: 48; y: 56; width: 150; height: 2; color: "#9ca3af" }
                }
            }

            RowLayout {
                Layout.leftMargin: 46
                Layout.rightMargin: 46
                Layout.fillWidth: true
                spacing: 14

                Button {
                    text: "−"
                    font.pixelSize: 24
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    onClicked: root.temperature = Math.max(16, root.temperature - 1)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 2
                        Text { text: root.temperature; font.pixelSize: 52; font.bold: true; color: "#111827" }
                        Text { text: "°C"; font.pixelSize: 24; color: "#111827"; Layout.alignment: Qt.AlignBottom }
                    }
                    Text { text: "Nhiệt độ hiện tại: 27°C"; color: "#6b7280"; font.pixelSize: 13; Layout.alignment: Qt.AlignHCenter }
                }

                Button {
                    text: "+"
                    font.pixelSize: 22
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    onClicked: root.temperature = Math.min(30, root.temperature + 1)
                }
            }

            ColumnLayout {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                spacing: 12

                Text { text: "Chế độ"; font.bold: true; color: "#111827"; font.pixelSize: 14 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: [
                            { icon: "❄", label: "Làm mát" },
                            { icon: "♨", label: "Sưởi ấm" },
                            { icon: "✽", label: "Quạt" },
                            { icon: "⏱", label: "Tự động" },
                            { icon: "💧", label: "Khử ẩm" }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 70
                            radius: 18
                            color: root.modeIndex === index ? "#1677ff" : "#ffffff"
                            border.width: 1
                            border.color: root.modeIndex === index ? "#1677ff" : "#edf1f7"
                            Column {
                                anchors.centerIn: parent
                                spacing: 5
                                Text { text: modelData.icon; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 19; color: root.modeIndex === index ? "#ffffff" : "#374151" }
                                Text { text: modelData.label; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 10; color: root.modeIndex === index ? "#ffffff" : "#374151" }
                            }
                            MouseArea { anchors.fill: parent; onClicked: root.modeIndex = index }
                        }
                    }
                }

                Text { text: "Tốc độ quạt"; font.bold: true; color: "#111827"; font.pixelSize: 14 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { text: "Tự động"; color: "#6b7280"; font.pixelSize: 13; Layout.preferredWidth: 64 }
                    Repeater {
                        model: [1, 2, 3, 4, 5]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 42
                            radius: 21
                            color: root.fanIndex === index ? "#1677ff" : "#ffffff"
                            border.width: 1
                            border.color: root.fanIndex === index ? "#1677ff" : "#edf1f7"
                            Text { anchors.centerIn: parent; text: modelData; color: root.fanIndex === index ? "#ffffff" : "#111827"; font.bold: root.fanIndex === index }
                            MouseArea { anchors.fill: parent; onClicked: root.fanIndex = index }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 18
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        Text { text: "Hẹn giờ"; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                        Text { text: "2 giờ ›"; color: "#6b7280" }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 18
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        Text { text: "Tiêu thụ điện"; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                        Text { text: "0.9 kWh (hôm nay) ›"; color: "#6b7280"; font.pixelSize: 12 }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    height: 58
                    text: "Tắt thiết bị"
                    font.bold: true
                }
            }
        }
    }

    Component {
        id: simpleDeviceDetail

        ColumnLayout {
            width: root.width
            spacing: 16

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: root.width - 52
                height: 160
                radius: 24
                color: "#ffffff"
                border.width: 1
                border.color: "#eef2f7"

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        text: root.simpleIcon()
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 54
                    }
                    Text {
                        text: root.deviceName
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.bold: true
                        color: "#111827"
                        font.pixelSize: 18
                    }
                    Text {
                        text: root.simpleHint()
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#6b7280"
                        font.pixelSize: 12
                    }
                }
            }

            ColumnLayout {
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    height: 62
                    radius: 18
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 14
                        Text { text: "Trạng thái"; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                        Text { text: root.deviceOn ? "Đang bật" : "Đang tắt"; color: root.deviceOn ? "#10b981" : "#6b7280"; font.pixelSize: 12 }
                        Switch {
                            checked: root.deviceOn
                            onToggled: root.deviceOn = checked
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: levelCol.implicitHeight + 28
                    radius: 20
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: levelCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: root.simpleTitle(); font.bold: true; color: "#111827"; Layout.fillWidth: true }
                            Text { text: root.simpleLevel + "%"; color: "#1677ff"; font.bold: true }
                        }

                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            stepSize: 1
                            value: root.simpleLevel
                            enabled: root.deviceOn
                            onMoved: root.simpleLevel = Math.round(value)
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.isLight ? "Kéo thanh trượt để thay đổi độ sáng." : (root.isFan ? "Kéo thanh trượt để thay đổi tốc độ quạt." : "Kéo thanh trượt để điều chỉnh mức hoạt động.")
                            color: "#6b7280"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 54
                    radius: 18
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        Text { text: "Tiêu thụ điện"; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                        Text { text: root.isLight ? "0.1 kWh (hôm nay)" : (root.isFan ? "0.3 kWh (hôm nay)" : "0.5 kWh (hôm nay)"); color: "#6b7280"; font.pixelSize: 12 }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    height: 58
                    text: root.deviceOn ? "Tắt thiết bị" : "Bật thiết bị"
                    font.bold: true
                    onClicked: root.deviceOn = !root.deviceOn
                }
            }
        }
    }
}
