import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    function money(value) {
        var rounded = Math.round(value).toString()
        return rounded.replace(/\B(?=(\d{3})+(?!\d))/g, ".") + " đ"
    }

    function powerStatus(value) {
        if (value < 500) return "Tiêu thụ thấp"
        if (value < 1500) return "Tiêu thụ trung bình"
        return "Tiêu thụ cao"
    }

    function averagePower() {
        var points = simulationEngine.dayPoints
        if (!points || points.length === 0) return 0

        var sum = 0
        for (var i = 0; i < points.length; i++)
            sum += Number(points[i].value)
        return sum / points.length
    }

    Connections {
        target: simulationEngine
        function onDataChanged() {
            sparkline.requestPaint()
        }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 18
            anchors.margins: 24

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "Trang chủ"
                        font.pixelSize: 30
                        font.bold: true
                        color: "#172033"
                    }

                    Text {
                        text: "Dữ liệu mô phỏng được cập nhật liên tục theo thời gian thực"
                        font.pixelSize: 14
                        color: "#6b7280"
                    }
                }

                Rectangle {
                    radius: 14
                    color: "#eaf2ff"
                    border.color: "#c7ddff"
                    Layout.preferredWidth: 230
                    Layout.preferredHeight: 54

                    Column {
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Cập nhật gần nhất"
                            color: "#4b5563"
                            font.pixelSize: 12
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: simulationEngine.lastUpdated
                            color: "#1d4ed8"
                            font.bold: true
                            font.pixelSize: 14
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: width > 900 ? 4 : 2
                columnSpacing: 14
                rowSpacing: 14

                InfoCard {
                    title: "Công suất hiện tại"
                    value: Math.round(simulationEngine.currentPowerW) + " W"
                    subtitle: powerStatus(simulationEngine.currentPowerW)
                    iconText: "⚡"
                }

                InfoCard {
                    title: "Điện năng hôm nay"
                    value: simulationEngine.todayKwh.toFixed(2) + " kWh"
                    subtitle: "Tăng tự động theo công suất"
                    iconText: "📊"
                }

                InfoCard {
                    title: "Chi phí tạm tính"
                    value: money(simulationEngine.todayCost)
                    subtitle: "Đơn giá mô phỏng 3.000 đ/kWh"
                    iconText: "💰"
                }

                InfoCard {
                    title: "Thiết bị đang hoạt động"
                    value: simulationEngine.activeDeviceCount + "/" + simulationEngine.totalDeviceCount
                    subtitle: "Tự thay đổi theo tải tiêu thụ"
                    iconText: "🏠"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 330
                    radius: 22
                    color: "#ffffff"
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: "Biến động công suất trong ngày"
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: "#111827"
                                }

                                Text {
                                    text: "Biểu đồ đường lấy trực tiếp từ SimulationEngine"
                                    color: "#6b7280"
                                    font.pixelSize: 13
                                }
                            }

                            Text {
                                text: "TB: " + Math.round(averagePower()) + " W"
                                color: "#2563eb"
                                font.pixelSize: 15
                                font.bold: true
                            }
                        }

                        Canvas {
                            id: sparkline
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)

                                var data = simulationEngine.dayPoints
                                var left = 46
                                var right = 16
                                var top = 18
                                var bottom = 34
                                var chartW = width - left - right
                                var chartH = height - top - bottom

                                ctx.strokeStyle = "#e5e7eb"
                                ctx.lineWidth = 1
                                ctx.beginPath()
                                ctx.moveTo(left, top)
                                ctx.lineTo(left, height - bottom)
                                ctx.lineTo(width - right, height - bottom)
                                ctx.stroke()

                                if (!data || data.length < 2) {
                                    ctx.fillStyle = "#6b7280"
                                    ctx.font = "14px sans-serif"
                                    ctx.fillText("Đang tạo dữ liệu mô phỏng...", left + 10, height / 2)
                                    return
                                }

                                var maxValue = 1
                                for (var i = 0; i < data.length; i++)
                                    maxValue = Math.max(maxValue, Number(data[i].value))

                                ctx.strokeStyle = "#2563eb"
                                ctx.lineWidth = 3
                                ctx.beginPath()

                                for (var j = 0; j < data.length; j++) {
                                    var x = left + j * (chartW / Math.max(1, data.length - 1))
                                    var y = height - bottom - Number(data[j].value) / maxValue * chartH
                                    if (j === 0) ctx.moveTo(x, y)
                                    else ctx.lineTo(x, y)
                                }
                                ctx.stroke()

                                ctx.fillStyle = "#2563eb"
                                for (var k = 0; k < data.length; k++) {
                                    var px = left + k * (chartW / Math.max(1, data.length - 1))
                                    var py = height - bottom - Number(data[k].value) / maxValue * chartH
                                    ctx.beginPath()
                                    ctx.arc(px, py, 3.5, 0, Math.PI * 2)
                                    ctx.fill()
                                }

                                ctx.fillStyle = "#6b7280"
                                ctx.font = "12px sans-serif"
                                ctx.fillText("0", 18, height - bottom + 4)
                                ctx.fillText(Math.round(maxValue) + "W", 8, top + 4)
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 290
                    Layout.preferredHeight: 330
                    radius: 22
                    color: "#ffffff"
                    border.color: "#e5e7eb"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Text {
                            text: "Môi trường mô phỏng"
                            font.pixelSize: 20
                            font.bold: true
                            color: "#111827"
                        }

                        MiniMetric {
                            label: "Nhiệt độ"
                            value: simulationEngine.temperatureC.toFixed(1) + " °C"
                        }

                        MiniMetric {
                            label: "Độ ẩm"
                            value: simulationEngine.humidity.toFixed(0) + " %"
                        }

                        MiniMetric {
                            label: "Trạng thái"
                            value: powerStatus(simulationEngine.currentPowerW)
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Reset dữ liệu hôm nay"
                            onClicked: simulationEngine.resetToday()
                        }

                        Text {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            color: "#6b7280"
                            font.pixelSize: 13
                            text: "Các chỉ số được tạo bằng bộ mô phỏng nội bộ, phù hợp để demo khi chưa kết nối thiết bị thật hoặc database thật."
                        }
                    }
                }
            }
        }
    }

    component InfoCard: Rectangle {
        property string title
        property string value
        property string subtitle
        property string iconText

        Layout.fillWidth: true
        Layout.preferredHeight: 146
        radius: 22
        color: "#ffffff"
        border.color: "#e5e7eb"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 16
                color: "#eff6ff"

                Text {
                    anchors.centerIn: parent
                    text: iconText
                    font.pixelSize: 24
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: title
                    color: "#6b7280"
                    font.pixelSize: 13
                }

                Text {
                    text: value
                    color: "#111827"
                    font.pixelSize: 27
                    font.bold: true
                }

                Text {
                    text: subtitle
                    color: "#2563eb"
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }

    component MiniMetric: Rectangle {
        property string label
        property string value

        Layout.fillWidth: true
        Layout.preferredHeight: 62
        radius: 16
        color: "#f9fafb"
        border.color: "#eef2f7"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14

            Text {
                Layout.fillWidth: true
                text: label
                color: "#4b5563"
                font.pixelSize: 14
            }

            Text {
                text: value
                color: "#111827"
                font.pixelSize: 16
                font.bold: true
            }
        }
    }
}
