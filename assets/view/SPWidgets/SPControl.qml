import QtQuick 2.15
import QtQuick.Controls 2.1

MouseArea {
    id: root
    opacity: enabled ? 1.0 : 0.3
    
    default property alias data: content.data

    property alias tooltip: tooltip
    property bool hovered: false

    hoverEnabled: enabled
    onEntered: hovered = true
    onExited: hovered = false

    Item {
        id: content
        anchors.fill: parent
    }

    ToolTip {
        id: tooltip
        delay: 500
        visible: root.hovered && text != ""
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        contentItem: Text {
            text: tooltip.text
            color: "#cfcfcf"
        }

        background: Rectangle {
            color: Qt.rgba(0.12, 0.12, 0.12)
            radius: 15
        }
    }
}
