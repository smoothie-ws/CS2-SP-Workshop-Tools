import QtQuick 2.7
import QtQuick.Controls 2.1

Button {
    id: root
    text: qsTr("Button")
    padding: 4
    opacity: enabled ? 1.0 : 0.3
    background: Rectangle {
        anchors.fill: parent
        color: root.hovered ? "#333333" : "#2d2d2d"
        border.color: root.checked ? "#378ef0" : "#4e4e4e"
        border.width: 1
        radius: 5
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: root.hovered ? "#378ef0" : "#cfcfcf"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        padding: 2
    }
}
