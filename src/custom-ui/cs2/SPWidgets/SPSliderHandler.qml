import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    width: 12
    height: 12
    radius: Math.min(width, height) * 0.5
    scale: hovered ? 1.25 : 1
    border.color: "#3b3b3b"
    border.width: 1.0

    property bool pressed: false
    property bool hovered: false
    property alias text: label.text

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.pressed ? 5.0 : (root.hovered ? 4.0 : 3.0)
        radius: Math.min(width, height) * 0.5
        color: root.pressed ? "#d0d0d0" : "#3b3b3b"
    }

    Label {
        id: label
        color: "#d0d0d0"
        opacity: root.hovered ? 1.0 : 0.0
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 9
        anchors.right: parent.left
        anchors.rightMargin: 2.5
        anchors.top: parent.bottom
        anchors.topMargin: 2.5
        
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
}
