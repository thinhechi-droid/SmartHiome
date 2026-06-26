pragma ComponentBehavior: Bound

import QtQuick
import "components"

Item {
    id: root
    signal logoutRequested()

    property string currentPage: "home"
    property string selectedRoom: "Phòng khách"
    property string selectedDevice: "Điều hòa phòng ngủ"
    property string roomReturnPage: "rooms"
    property string deviceReturnPage: "home"
    property string addReturnPage: "home"
    property string historyReturnPage: "stats"
    property string alertsReturnPage: "home"

    // Các thiết bị được thêm trong lúc chạy app simulation.
    // Dùng property var + gán lại mảng mới để QML tự cập nhật giao diện.
    property var addedDevices: []

    QtObject {
        id: appSettings
        property string homeName: "Nhà của tôi"
        property string homeAddress: "Khu vực mô phỏng"
        property var memberNames: ["Chủ nhà", "Thành viên gia đình"]
        property int pricePerKwh: 2436
        property string energyUnit: "kWh"
        property string currencyUnit: "đ"
        property string lastBackup: "Chưa có bản sao lưu"
        property int dailyThreshold: 20
        property int monthlyThreshold: 600
        property int budgetThreshold: 1500000
        property int acHours: 8
        property int heaterMinutes: 60
        property int lightHours: 6
        property bool notificationsEnabled: true
        property bool autoTurnOffEnabled: true
    }

    function money(v) {
        return Math.round(v).toLocaleString(Qt.locale("vi_VN")) + " đ"
    }

    function go(page) {
        currentPage = page
    }

    function openAddDevice(returnPage) {
        addReturnPage = returnPage || currentPage || "home"
        currentPage = "add"
    }

    function openRoom(room, returnPage) {
        selectedRoom = room
        roomReturnPage = returnPage || currentPage || "rooms"
        currentPage = "roomDevices"
    }

    function openDevice(name, returnPage) {
        selectedDevice = name
        deviceReturnPage = returnPage || currentPage || "home"
        currentPage = "deviceDetail"
    }

    function openHistory(returnPage) {
        historyReturnPage = returnPage || currentPage || "stats"
        currentPage = "history"
    }

    function openAlerts(returnPage) {
        alertsReturnPage = returnPage || currentPage || "home"
        currentPage = "alerts"
    }

    function openThresholds() {
        currentPage = "thresholds"
    }

    function normalizeType(name, type) {
        var text = ((type || "") + " " + (name || "")).toLowerCase()
        if (text.indexOf("điều hòa") >= 0 || text.indexOf("dieu hoa") >= 0 || text.indexOf("máy lạnh") >= 0)
            return "ac"
        if (text.indexOf("đèn") >= 0 || text.indexOf("den") >= 0)
            return "light"
        if (text.indexOf("quạt") >= 0 || text.indexOf("quat") >= 0)
            return "fan"
        if (text.indexOf("tivi") >= 0 || text.indexOf("tv") >= 0)
            return "tv"
        return "other"
    }

    function iconForType(type) {
        if (type === "ac") return "▭"
        if (type === "light") return "💡"
        if (type === "fan") return "🌀"
        if (type === "tv") return "▣"
        return "▣"
    }

    function sliderLabelForType(type) {
        if (type === "ac") return "Nhiệt độ:"
        if (type === "light") return "Độ sáng:"
        if (type === "fan") return "Tốc độ:"
        return "Mức dùng:"
    }

    function addDevice(device) {
        var type = normalizeType(device.name, device.type)
        var item = {
            room: device.room || selectedRoom || "Phòng khách",
            icon: device.icon || iconForType(type),
            name: device.name || "Thiết bị mới",
            power: device.power || "0 W",
            on: true,
            type: type,
            slider: type === "ac" || type === "light" || type === "fan",
            sliderLabel: sliderLabelForType(type),
            sliderValue: type === "ac" ? 64 : 70
        }

        // Tránh thêm trùng cùng tên trong cùng phòng khi bấm nhiều lần.
        for (var i = 0; i < addedDevices.length; i++) {
            if (addedDevices[i].room === item.room && addedDevices[i].name === item.name) {
                selectedRoom = item.room
                currentPage = "roomDevices"
                return
            }
        }

        var list = addedDevices.slice()
        list.push(item)
        addedDevices = list
        selectedRoom = item.room
        selectedDevice = item.name
        currentPage = "roomDevices"
    }

    Rectangle { anchors.fill: parent; color: "#eef4ff" }

    Rectangle {
        id: phone
        width: Math.min(parent.width, 420)
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#f8fbff"

        Loader {
            id: pageLoader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: bottomNav.top
            sourceComponent: {
                if (root.currentPage === "home") return homeComponent
                if (root.currentPage === "add") return addComponent
                if (root.currentPage === "rooms") return roomsComponent
                if (root.currentPage === "roomDevices") return roomDevicesComponent
                if (root.currentPage === "deviceDetail") return deviceDetailComponent
                if (root.currentPage === "stats") return statsComponent
                if (root.currentPage === "history") return historyComponent
                if (root.currentPage === "alerts") return alertsComponent
                if (root.currentPage === "thresholds") return thresholdsComponent
                return settingsComponent
            }
        }

        BottomNav {
            id: bottomNav
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            current: root.currentPage === "roomDevices" || root.currentPage === "deviceDetail" ? "rooms" : root.currentPage
            onSelected: function(page) {
                if (page === "add")
                    root.openAddDevice("home")
                else
                    root.go(page)
            }
        }
    }

    Component {
        id: homeComponent
        HomeView {
            formatMoney: root.money
            onOpenRooms: root.go("rooms")
            onOpenAddDevice: root.openAddDevice("home")
            onOpenStats: root.go("stats")
            onOpenAlerts: root.openAlerts("home")
            onOpenRoom: function(roomName) { root.openRoom(roomName, "home") }
            onOpenDevice: function(deviceName) { root.openDevice(deviceName, "home") }
        }
    }

    Component {
        id: roomsComponent
        RoomsView {
            extraDevices: root.addedDevices
            onOpenRoom: function(roomName) { root.openRoom(roomName, "rooms") }
            onOpenAddDevice: root.openAddDevice("rooms")
        }
    }

    Component {
        id: roomDevicesComponent
        RoomDevicesView {
            roomName: root.selectedRoom
            extraDevices: root.addedDevices
            navigateBack: function() { root.go(root.roomReturnPage) }
            onOpenAddDevice: root.openAddDevice("roomDevices")
            onOpenDevice: function(deviceName) { root.openDevice(deviceName, "roomDevices") }
        }
    }

    Component {
        id: deviceDetailComponent
        DeviceDetailView {
            deviceName: root.selectedDevice
            navigateBack: function() { root.go(root.deviceReturnPage) }
        }
    }

    Component {
        id: addComponent
        AddDeviceView {
            navigateBack: function() { root.go(root.addReturnPage) }
            onDeviceAdded: function(device) { root.addDevice(device) }
        }
    }

    Component {
        id: statsComponent
        StatisticsView {
            formatMoney: root.money
            onOpenHistory: root.openHistory("stats")
        }
    }

    Component {
        id: historyComponent
        HistoryView {
            formatMoney: root.money
            navigateBack: function() { root.go(root.historyReturnPage) }
        }
    }

    Component {
        id: alertsComponent
        AlertsView {
            navigateBack: function() { root.go(root.alertsReturnPage) }
        }
    }

    Component {
        id: thresholdsComponent
        ThresholdSettingsView {
            settingsState: appSettings
            navigateBack: function() { root.go("settings") }
        }
    }

    Component {
        id: settingsComponent
        SettingsView {
            settingsState: appSettings
            onOpenThresholds: root.openThresholds()
            onOpenHistory: root.openHistory("settings")
            onOpenAlerts: root.openAlerts("settings")
            onLogoutRequested: root.logoutRequested()
        }
    }
}
