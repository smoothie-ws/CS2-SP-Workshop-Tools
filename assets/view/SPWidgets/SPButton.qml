import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1

SPControl {
    id: root
    implicitHeight: Math.max(checker.height, icon.height, label.height) + padding * 2.0
    implicitWidth: checker.width + icon.width + label.width + padding * 2.0

    property alias text: label.text
    property alias font: label.font
    property alias icon: icon
    property alias label: label
    property alias checker: checker
    property alias background: background
    property alias padding: content.anchors.margins

    property int contentAlignment: Qt.AlignCenter
    property bool checked: false
    property bool checkable: false

    cursorShape: Qt.PointingHandCursor
    onPressed: {
        background.anchors.margins = -2.0;
        if (checkable)
            checked = !checked;
    }
    onReleased: background.anchors.margins = 0.0
    tooltip.visible: root.hovered && tooltip.text != ""

    onCheckableChanged: checker.visible = checkable
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: root.hovered ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
        radius: 15

        Behavior on color {
            ColorAnimation { duration: 250 }
        }

        Behavior on anchors.margins {
            NumberAnimation { duration: 50 }
        }
    }

    Row {
        id: content
        spacing: 5
        anchors.margins: 5
        anchors.left: parseInt(root.contentAlignment & Qt.AlignLeft) != 0 ? parent.left : undefined
        anchors.horizontalCenter: parseInt(root.contentAlignment & Qt.AlignHCenter) != 0 ? parent.horizontalCenter : undefined
        anchors.right: parseInt(root.contentAlignment & Qt.AlignRight) != 0 ? parent.right : undefined
        anchors.top: parseInt(root.contentAlignment & Qt.AlignTop) != 0 ? parent.top : undefined
        anchors.verticalCenter: parseInt(root.contentAlignment & Qt.AlignVCenter) != 0 ? parent.verticalCenter : undefined
        anchors.bottom: parseInt(root.contentAlignment & Qt.AlignBottom) != 0 ? parent.bottom : undefined

        Rectangle {
            id: checker
            anchors.verticalCenter: parent.verticalCenter
            visible: false
            width: 15
            height: 15
            radius: width
            color: root.checked ? "#cfcfcf" : (root.hovered ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.35))
            border.width: root.hovered ? 3 : 4
            border.color: Qt.rgba(0, 0, 0, 0.35)
        }

        Image {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            asynchronous: true
            visible: source !== ""
            opacity: root.hovered ? 1.0 : 0.5
            sourceSize.width: width
            sourceSize.height: height
        }

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            color: "#cfcfcf"
            verticalAlignment: Text.AlignVCenter
            padding: 2
        }
    }
}
