import QtQuick

Canvas {
    id: root
    property var points: []
    property string lineColor: "#1677ff"
    property bool showLabels: false
    property string emptyText: "Đang chờ dữ liệu..."

    height: 230
    onPointsChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var p = root.points || []
        var left = 36
        var right = 14
        var top = 18
        var bottom = 34
        var cw = width - left - right
        var ch = height - top - bottom

        ctx.strokeStyle = "#e5eaf2"
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.moveTo(left, top)
        ctx.lineTo(left, height - bottom)
        ctx.lineTo(width - right, height - bottom)
        ctx.stroke()

        if (p.length < 2) {
            ctx.fillStyle = "#6b7280"
            ctx.font = "14px sans-serif"
            ctx.fillText(root.emptyText, left, height / 2)
            return
        }

        var maxValue = 0.1
        for (var i = 0; i < p.length; ++i) {
            maxValue = Math.max(maxValue, Number(p[i].value))
        }
        maxValue = maxValue * 1.15

        ctx.strokeStyle = "#eff3f8"
        ctx.lineWidth = 1
        for (var g = 1; g <= 4; ++g) {
            var gy = top + ch * g / 4
            ctx.beginPath()
            ctx.moveTo(left, gy)
            ctx.lineTo(width - right, gy)
            ctx.stroke()
        }

        ctx.strokeStyle = root.lineColor
        ctx.lineWidth = 3
        ctx.beginPath()
        for (var j = 0; j < p.length; ++j) {
            var x = left + j * cw / Math.max(1, p.length - 1)
            var y = height - bottom - Number(p[j].value) / maxValue * ch
            if (j === 0) ctx.moveTo(x, y)
            else ctx.lineTo(x, y)
        }
        ctx.stroke()

        ctx.fillStyle = root.lineColor
        for (var k = 0; k < p.length; ++k) {
            var px = left + k * cw / Math.max(1, p.length - 1)
            var py = height - bottom - Number(p[k].value) / maxValue * ch
            ctx.beginPath()
            ctx.arc(px, py, 4, 0, Math.PI * 2)
            ctx.fill()
        }

        ctx.fillStyle = "#6b7280"
        ctx.font = "11px sans-serif"
        ctx.fillText("kWh", 4, top + 4)

        if (root.showLabels) {
            for (var m = 0; m < p.length; m += Math.max(1, Math.floor(p.length / 6))) {
                var lx = left + m * cw / Math.max(1, p.length - 1)
                ctx.fillText(String(p[m].label), lx - 8, height - 12)
            }
        } else {
            ctx.fillText("00", left - 4, height - 12)
            ctx.fillText("24", width - right - 12, height - 12)
        }
    }
}
