import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Item {
    id: root

    property var formatMoney: function(v) { return Math.round(v) + " đ" }
    property int tabIndex: 1
    property int periodOffset: 0

    signal openHistory()

    property var monthBars: [
        { label: "01", value: 18.2 },
        { label: "05", value: 22.6 },
        { label: "10", value: 19.7 },
        { label: "15", value: 25.4 },
        { label: "20", value: 21.8 },
        { label: "25", value: 28.1 },
        { label: "30", value: 24.5 }
    ]

    property var yearBars: [
        { label: "T1", value: 520 },
        { label: "T2", value: 486 },
        { label: "T3", value: 548 },
        { label: "T4", value: 572 },
        { label: "T5", value: 615 },
        { label: "T6", value: 642 },
        { label: "T7", value: 688 },
        { label: "T8", value: 674 },
        { label: "T9", value: 590 },
        { label: "T10", value: 556 },
        { label: "T11", value: 531 },
        { label: "T12", value: 603 }
    ]

    function shiftedDate(days) {
        var d = new Date()
        d.setDate(d.getDate() + days)
        return d
    }

    function shiftedMonth(months) {
        var d = new Date()
        d.setMonth(d.getMonth() + months)
        return d
    }

    function weekLabel(offset) {
        var start = shiftedDate(offset * 7)
        var day = start.getDay()
        var mondayDelta = day === 0 ? -6 : 1 - day
        start.setDate(start.getDate() + mondayDelta)

        var end = new Date(start)
        end.setDate(start.getDate() + 6)
        return Qt.formatDate(start, "dd/MM") + " - " + Qt.formatDate(end, "dd/MM/yyyy")
    }

    function periodLabel() {
        if (tabIndex === 0)
            return Qt.formatDate(shiftedDate(periodOffset), "dd/MM/yyyy")
        if (tabIndex === 1)
            return weekLabel(periodOffset)
        if (tabIndex === 2)
            return "Tháng " + Qt.formatDate(shiftedMonth(periodOffset), "MM/yyyy")

        var y = new Date().getFullYear() + periodOffset
        return "Năm " + y
    }

    function periodScale() {
        return Math.max(0.72, 1 + periodOffset * 0.035)
    }

    function scaledBars(data) {
        var result = []
        var scale = periodScale()
        for (var i = 0; i < data.length; ++i)
            result.push({ label: data[i].label, value: Number(data[i].value) * scale })
        return result
    }

    function barsForPeriod() {
        if (tabIndex === 1)
            return scaledBars(simulationEngine.weekBars)
        if (tabIndex === 2)
            return scaledBars(root.monthBars)
        if (tabIndex === 3)
            return scaledBars(root.yearBars)
        return []
    }

    function sumBars(data) {
        var total = 0
        for (var i = 0; i < data.length; ++i)
            total += Number(data[i].value)
        return total
    }

    function totalKwh() {
        if (tabIndex === 0)
            return Math.max(0, simulationEngine.todayKwh * periodScale())
        return sumBars(barsForPeriod())
    }

    function chartTitle() {
        if (tabIndex === 0)
            return "Công suất theo giờ trong ngày"
        if (tabIndex === 1)
            return "Điện năng theo ngày trong tuần"
        if (tabIndex === 2)
            return "Điện năng theo các mốc ngày trong tháng"
        return "Điện năng theo tháng trong năm"
    }

    function deviceTitle() {
        if (tabIndex === 0)
            return "Tiêu thụ theo thiết bị (hôm nay)"
        if (tabIndex === 1)
            return "Tiêu thụ theo thiết bị (tuần này)"
        if (tabIndex === 2)
            return "Tiêu thụ theo thiết bị (tháng này)"
        return "Tiêu thụ theo thiết bị (năm nay)"
    }

    function movePeriod(delta) {
        periodOffset += delta
        refreshChart()
    }

    function refreshChart() {
        if (chartLoader.item && chartLoader.item.requestPaint)
            chartLoader.item.requestPaint()
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

            PageHeader { title: "Thống kê" }

            ColumnLayout {
                Layout.leftMargin: 18
                Layout.rightMargin: 18
                Layout.fillWidth: true
                spacing: 14

                SegmentedTabs {
                    Layout.fillWidth: true
                    tabs: ["Ngày", "Tuần", "Tháng", "Năm"]
                    currentIndex: root.tabIndex
                    onChanged: function(index) {
                        root.tabIndex = index
                        root.periodOffset = 0
                        root.refreshChart()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: "‹"
                        flat: true
                        Layout.preferredWidth: 42
                        onClicked: root.movePeriod(-1)
                    }

                    Text {
                        text: root.periodLabel()
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        color: "#111827"
                        font.bold: true
                    }

                    Button {
                        text: "›"
                        flat: true
                        Layout.preferredWidth: 42
                        onClicked: root.movePeriod(1)
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: summaryCol.implicitHeight + 26
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    RowLayout {
                        id: summaryCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Text {
                                text: "Tổng tiêu thụ"
                                color: "#6b7280"
                                font.pixelSize: 12
                            }

                            Text {
                                text: root.totalKwh().toFixed(root.tabIndex === 3 ? 0 : 1) + " kWh"
                                color: "#111827"
                                font.pixelSize: 25
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignRight

                            Text {
                                text: "Chi phí tạm tính"
                                color: "#6b7280"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "≈ " + root.formatMoney(root.totalKwh() * simulationEngine.pricePerKwh)
                                color: "#111827"
                                font.bold: true
                                horizontalAlignment: Text.AlignRight
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Text {
                    text: root.chartTitle()
                    Layout.fillWidth: true
                    font.bold: true
                    color: "#111827"
                    font.pixelSize: 14
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 260
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    Loader {
                        id: chartLoader
                        anchors.fill: parent
                        anchors.margins: 12
                        sourceComponent: root.tabIndex === 0 ? lineComponent : barComponent
                    }

                    Component {
                        id: lineComponent
                        LineChart {
                            anchors.fill: parent
                            points: simulationEngine.dayLinePoints
                            showLabels: true
                            emptyText: "Dữ liệu ngày đang được cập nhật..."
                            Connections {
                                target: simulationEngine
                                function onDataChanged() { parent.requestPaint() }
                            }
                        }
                    }

                    Component {
                        id: barComponent
                        BarChart {
                            anchors.fill: parent
                            bars: root.barsForPeriod()
                            barColor: root.tabIndex === 2 ? "#10b981" : root.tabIndex === 3 ? "#7c3aed" : "#1677ff"
                            Connections {
                                target: simulationEngine
                                function onDataChanged() { parent.requestPaint() }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: root.deviceTitle()
                        Layout.fillWidth: true
                        font.bold: true
                        color: "#111827"
                        font.pixelSize: 14
                    }
                    Button {
                        text: "Lịch sử ›"
                        flat: true
                        onClicked: root.openHistory()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: deviceCol.implicitHeight + 22
                    radius: 22
                    color: "#ffffff"
                    border.width: 1
                    border.color: "#edf1f7"

                    ColumnLayout {
                        id: deviceCol
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        spacing: 10

                        Repeater {
                            model: simulationEngine.deviceConsumption
                            delegate: ColumnLayout {
                                required property var modelData

                                Layout.fillWidth: true
                                spacing: 5

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.name
                                        Layout.fillWidth: true
                                        color: "#111827"
                                        font.bold: true
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: Number(modelData.kwh * (root.tabIndex + 1) * 0.85).toFixed(1) + " kWh"
                                        color: "#374151"
                                        font.pixelSize: 12
                                    }
                                    Text {
                                        text: modelData.percent + "%"
                                        color: "#1677ff"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 5
                                    radius: 3
                                    color: "#edf1f7"
                                    Rectangle {
                                        width: parent.width * modelData.percent / 40
                                        height: parent.height
                                        radius: 3
                                        color: "#1677ff"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
