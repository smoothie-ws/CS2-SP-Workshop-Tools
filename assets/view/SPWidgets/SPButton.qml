import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1

SPControl {
    id: root
    height: 25
    implicitWidth: content.implicitWidth + padding * 2.0

    property alias text: label.text
    property alias font: label.font
    property alias icon: icon
    property alias label: label
    property alias checker: checker
    property alias background: background
    property alias padding: content.anchors.margins

    property int contentAlignment: Qt.AlignLeft | Qt.AlignRight | Qt.AlignVCenter
    property bool checked: false
    property bool checkable: false

    cursorShape: Qt.PointingHandCursor
    onPressed: {
        background.anchors.margins = 0.5;
        if (checkable)
            checked = !checked;
    }
    onReleased: background.anchors.margins = -1.0
    tooltip.visible: root.hovered && tooltip.text != ""

    onCheckableChanged: checker.visible = checkable
    
    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: -1.0
        color: root.hovered ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
        opacity: root.checkable ? 0.0 : 1.0
        radius: 15

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Behavior on anchors.margins {
            NumberAnimation { duration: 50 }
        }
    }

    RowLayout {
        id: content
        anchors.margins: root.checkable ? 0.0 : 5.0
        anchors.left: parseInt(root.contentAlignment & Qt.AlignLeft) != 0 ? parent.left : undefined
        anchors.horizontalCenter: parseInt(root.contentAlignment & Qt.AlignHCenter) != 0 ? parent.horizontalCenter : undefined
        anchors.right: parseInt(root.contentAlignment & Qt.AlignRight) != 0 ? parent.right : undefined
        anchors.top: parseInt(root.contentAlignment & Qt.AlignTop) != 0 ? parent.top : undefined
        anchors.verticalCenter: parseInt(root.contentAlignment & Qt.AlignVCenter) != 0 ? parent.verticalCenter : undefined
        anchors.bottom: parseInt(root.contentAlignment & Qt.AlignBottom) != 0 ? parent.bottom : undefined

        Image {
            id: icon
            asynchronous: true
            visible: status == Image.Ready
            opacity: root.hovered ? 1.0 : 0.5
            height: parent.height
            width: height
            sourceSize.width: width
            sourceSize.height: height

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        Text {
            id: label
            visible: text !== ""
            color: "#cfcfcf"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: checker.visible ? Text.AlignLeft : Text.AlignHCenter
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth + 25
        }

        Rectangle {
            id: checker
            visible: false
            width: 30
            height: 15
            radius: height
            color: Qt.hsva(0.0, 0.0, root.checked ? 0.3 : 0.15, root.hovered ? 0.5 : 1.0)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutQuart
                }
            }

            Rectangle {
                x: root.checked ? parent.width - width - 2 : 2
                width: height
                radius: width
                anchors.margins: 2.5
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: root.hovered ? "#cfcfcf" : "#b3b3b3"

                Behavior on x {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuart
                    }
                }
            }
        }
    }
}
