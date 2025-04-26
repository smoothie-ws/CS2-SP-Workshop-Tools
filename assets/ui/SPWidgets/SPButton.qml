import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

Button {
    id: root
    opacity: enabled ? 1.0 : 0.3
    padding: 5
    implicitHeight: Math.max(checker.height, icon.height, label.height) + padding * 2.0
    implicitWidth: checker.width + icon.width + label.width + padding * 2.0

    property int contentAlignment: Qt.AlignCenter
    property alias tooltip: tooltip
    property alias label: label
    property alias backgroundRect: backgroundRect

    onPressed: scale = 0.95
    onReleased: scale = 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 50
        }
    }

    background: Rectangle {
        id: backgroundRect
        anchors.fill: parent
        opacity: root.hovered ? 0.1 : 0.05
        color: "white"
        radius: 15

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }

    contentItem: Item {
        anchors.fill: parent

        RowLayout {
            anchors.margins: root.padding
            anchors.left: parseInt(root.contentAlignment & Qt.AlignLeft) != 0 ? parent.left : undefined
            anchors.horizontalCenter: parseInt(root.contentAlignment & Qt.AlignHCenter) != 0 ? parent.horizontalCenter : undefined
            anchors.right: parseInt(root.contentAlignment & Qt.AlignRight) != 0 ? parent.right : undefined
            anchors.top: parseInt(root.contentAlignment & Qt.AlignTop) != 0 ? parent.top : undefined
            anchors.verticalCenter: parseInt(root.contentAlignment & Qt.AlignVCenter) != 0 ? parent.verticalCenter : undefined
            anchors.bottom: parseInt(root.contentAlignment & Qt.AlignBottom) != 0 ? parent.bottom : undefined
            spacing: 5

            Rectangle {
                id: checker
                visible: root.checkable
                height: 15
                width: 15
                radius: width
                color: root.checked ? "#cfcfcf" : (root.hovered ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.35))
                border.width: root.hovered ? 3 : 4
                border.color: Qt.rgba(0, 0, 0, 0.35)
            }

            Image {
                id: icon
                source: root.icon.source
                sourceSize.width: root.icon.width
                sourceSize.height: root.icon.height
                visible: root.icon.source !== ""
                opacity: root.hovered ? 1.0 : 0.5
            }

            Label {
                id: label
                Layout.fillWidth: true
                visible: root.text != ""
                text: root.text
                font: root.font
                color: "#cfcfcf"
                verticalAlignment: Text.AlignVCenter
                padding: 2
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: (e) => e.accepted = false
        onReleased: (e) => e.accepted = false
        onClicked: (e) => e.accepted = false
        onDoubleClicked: (e) => e.accepted = false
        onPressAndHold: (e) => e.accepted = false
        onWheel: (e) => e.accepted = false
        onPositionChanged: (e) => e.accepted = false
    }

    ToolTip {
        id: tooltip
        visible: root.hovered && text != ""
        opacity: visible ? 1.0 : 0.0
        delay: 500

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        contentItem: Text {
            text: tooltip.text
            color: "#cfcfcf"
        }

        background: Rectangle {
            color: Qt.rgba(0.12, 0.12, 0.12)
            radius: 5
        }
    }
}
