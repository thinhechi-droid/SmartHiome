import QtQuick

Canvas {
    id: root
    property var bars: []
    property string barColor: "#1677ff"
    property string emptyText: "Chưa có dữ liệu"

    height: 230
    onBarsChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var data = root.bars || []
        var left = 36
        var right = 16
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

        if (data.length === 0) {
            ctx.fillStyle = "#6b7280"
            ctx.font = "14px sans-serif"
            ctx.fillText(root.emptyText, left, height / 2)
            return
        }

        var maxValue = 1
        for (var i = 0; i < data.length; ++i)
            maxValue = Math.max(maxValue, Number(data[i].value))
        maxValue = maxValue * 1.2

        ctx.fillStyle = root.barColor
        for (var j = 0; j < data.length; ++j) {
            var section = cw / data.length
            var bw = Math.min(24, section * 0.55)
            var x = left + j * section + (section - bw) / 2
            var bh = Number(data[j].value) / maxValue * ch
            var y = height - bottom - bh
            ctx.fillRect(x, y, bw, bh)

            ctx.fillStyle = "#6b7280"
            ctx.font = "11px sans-serif"
            ctx.fillText(String(data[j].label), x + bw / 2 - 7, height - 12)
            ctx.fillStyle = root.barColor
        }

        ctx.fillStyle = "#6b7280"
        ctx.font = "11px sans-serif"
        ctx.fillText("kWh", 4, top + 4)
    }
}
