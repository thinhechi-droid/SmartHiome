import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root
    property string roomName: "Phòng khách"
    property var extraDevices: []
    property var navigateBack: null

    signal back()
    signal openAddDevice()
    signal openDevice(string deviceName)

    property var baseDevices: [
        { room: "Phòng khách", type: "light", icon: "💡", name: "Đèn trần", power: "10 W", on: true, slider: true, sliderLabel: "Độ sáng:", sliderValue: 80 },
        { room: "Phòng khách", type: "fan", icon: "🌀", name: "Quạt đứng", power: "45 W", on: true, slider: true, sliderLabel: "Tốc độ:", sliderValue: 60 },
        { room: "Phòng khách", type: "tv", icon: "▣", name: "Tivi", power: "120 W", on: true, slider: false },
        { room: "Phòng khách", type: "ac", icon: "▭", name: "Điều hòa", power: "900 W", on: true, slider: true, sliderLabel: "Nhiệt độ:", sliderValue: 68 },
        { room: "Phòng khách", type: "curtain", icon: "▤", name: "Rèm cửa", power: "30 W", on: false, slider: false },
        { room: "Phòng ngủ", type: "ac", icon: "▭", name: "Điều hòa phòng ngủ", power: "900 W", on: true, slider: true, sliderLabel: "Nhiệt độ:", sliderValue: 62 },
        { room: "Phòng ngủ", type: "light", icon: "💡", name: "Đèn ngủ", power: "8 W", on: true, slider: true, sliderLabel: "Độ sáng:", sliderValue: 40 },
        { room: "Phòng ngủ", type: "fan", icon: "🌀", name: "Quạt phòng ngủ", power: "45 W", on: false, slider: true, sliderLabel: "Tốc độ:", sliderValue: 35 },
        { room: "Bếp", type: "other", icon: "▣", name: "Tủ lạnh", power: "160 W", on: true, slider: false },
        { room: "Bếp", type: "other", icon: "🔥", name: "Bếp điện", power: "1500 W", on: false, slider: false },
        { room: "Bếp", type: "light", icon: "💡", name: "Đèn bếp", power: "12 W", on: true, slider: true, sliderLabel: "Độ sáng:", sliderValue: 70 },
        { room: "Phòng giặt", type: "other", icon: "▣", name: "Máy giặt", power: "500 W", on: false, slider: false },
        { room: "Phòng tắm", type: "other", icon: "♨", name: "Bình nóng lạnh", power: "1800 W", on: false, slider: false }
    ]

    function allDevices() {
        return baseDevices.concat(extraDevices)
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
        contentHeight: mainCol.implicitHeight + 26
        clip: true

        ColumnLayout {
            id: mainCol
            width: parent.width
            spacing: 14

            PageHeader {
                title: root.roomName
                showBack: true
                showAdd: true
                onBackClicked: root.goBack()
                onAddClicked: root.openAddDevice()
            }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    height: 44
                    radius: 15
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#e9eef6"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 8
                        Text { text: "🔍"; font.pixelSize: 15; color: "#9ca3af" }
                        TextField {
                            id: search
                            Layout.fillWidth: true
                            placeholderText: "Tìm kiếm thiết bị trong phòng"
                            background: Item {}
                            font.pixelSize: 13
                        }
                    }
                }

                Repeater {
                    model: root.allDevices()
                    delegate: DeviceRow {
                        Layout.fillWidth: true
                        visible: modelData.room === root.roomName &&
                                 (search.text.length === 0 || modelData.name.toLowerCase().indexOf(search.text.toLowerCase()) >= 0)
                        height: visible ? (modelData.slider ? 108 : 72) : 0
                        name: modelData.name
                        icon: modelData.icon
                        detail: modelData.power
                        checked: modelData.on
                        showSlider: modelData.slider
                        sliderLabel: modelData.sliderLabel || ""
                        sliderValue: modelData.sliderValue || 0
                        onClicked: root.openDevice(modelData.name)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "Không thấy thiết bị cần tìm? Bấm dấu + để quét hoặc thêm thủ công."
                    color: "#6b7280"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
