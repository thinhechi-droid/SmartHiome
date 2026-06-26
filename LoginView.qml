import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal loginSuccess()

    function submitLogin() {
        if (username.text === "admin" && password.text === "123456") {
            errorText.text = ""
            root.loginSuccess()
        } else {
            errorText.text = "Sai tài khoản hoặc mật khẩu"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#edf4ff"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height * 0.42
        color: "#dbeafe"

        Rectangle {
            width: 190
            height: 190
            radius: 95
            x: parent.width - 120
            y: -54
            color: "#bbf7d0"
            opacity: 0.48
        }

        Rectangle {
            width: 150
            height: 150
            radius: 75
            x: -54
            y: 72
            color: "#bfdbfe"
            opacity: 0.75
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 42
        anchors.bottomMargin: 24
        spacing: 18

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 62
                Layout.preferredHeight: 62
                radius: 22
                color: "#ffffff"
                border.width: 1
                border.color: "#dbeafe"

                Text {
                    anchors.centerIn: parent
                    text: "⌂"
                    color: "#1677ff"
                    font.pixelSize: 34
                    font.bold: true
                }
            }

            Text {
                Layout.fillWidth: true
                text: "Ứng dụng Smart Home"
                color: "#0f172a"
                font.pixelSize: 28
                font.bold: true
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Giám sát điện tiêu thụ và điều khiển thiết bị từ xa"
                color: "#475569"
                font.pixelSize: 14
                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            radius: 22
            color: "#ffffff"
            border.width: 1
            border.color: "#e2e8f0"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 14

                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    radius: 21
                    color: "#ecfdf5"

                    Text {
                        anchors.centerIn: parent
                        text: "⚡"
                        color: "#16a34a"
                        font.pixelSize: 22
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Hệ thống mô phỏng đang sẵn sàng"
                        color: "#0f172a"
                        font.bold: true
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Theo dõi kWh, tiền điện, phòng và thiết bị"
                        color: "#64748b"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 390
            radius: 28
            color: "#ffffff"
            border.width: 1
            border.color: "#e2e8f0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 14

                Text {
                    text: "Đăng nhập"
                    color: "#0f172a"
                    font.pixelSize: 22
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "Nhập tài khoản demo để vào giao diện quản lý nhà thông minh."
                    color: "#64748b"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                Item { Layout.preferredHeight: 2 }

                Text {
                    text: "Tài khoản"
                    color: "#334155"
                    font.pixelSize: 12
                    font.bold: true
                }

                TextField {
                    id: username
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    text: "admin"
                    placeholderText: "Nhập tài khoản"
                    leftPadding: 16
                    rightPadding: 16
                    selectByMouse: true
                    background: Rectangle {
                        radius: 16
                        color: username.activeFocus ? "#f8fbff" : "#f9fafb"
                        border.width: 1
                        border.color: username.activeFocus ? "#1677ff" : "#e5e7eb"
                    }
                    onAccepted: password.forceActiveFocus()
                }

                Text {
                    text: "Mật khẩu"
                    color: "#334155"
                    font.pixelSize: 12
                    font.bold: true
                }

                TextField {
                    id: password
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    text: "123456"
                    placeholderText: "Nhập mật khẩu"
                    echoMode: TextInput.Password
                    leftPadding: 16
                    rightPadding: 16
                    selectByMouse: true
                    background: Rectangle {
                        radius: 16
                        color: password.activeFocus ? "#f8fbff" : "#f9fafb"
                        border.width: 1
                        border.color: password.activeFocus ? "#1677ff" : "#e5e7eb"
                    }
                    onAccepted: root.submitLogin()
                }

                Text {
                    id: errorText
                    Layout.fillWidth: true
                    text: ""
                    color: "#ef4444"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Button {
                    id: loginButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    text: "Đăng nhập"
                    font.bold: true
                    onClicked: root.submitLogin()

                    contentItem: Text {
                        text: loginButton.text
                        color: "#ffffff"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 18
                        color: loginButton.down ? "#0f5ed7" : "#1677ff"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 16
                    color: "#f8fafc"
                    border.width: 1
                    border.color: "#edf2f7"

                    Text {
                        anchors.centerIn: parent
                        text: "Tài khoản demo: admin / 123456"
                        color: "#64748b"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
