pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: window
    visible: true
    width: 420
    height: 860
    minimumWidth: 380
    minimumHeight: 760
    title: "Ứng dụng Smart Home"
    color: "#eef4ff"

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loginComponent
    }

    Component {
        id: loginComponent
        LoginView {
            onLoginSuccess: stack.replace(appShellComponent)
        }
    }

    Component {
        id: appShellComponent
        AppShell {
            onLogoutRequested: stack.replace(loginComponent)
        }
    }
}
