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

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.pressed ? 5.0 : (root.hovered ? 4.0 : 3.0)
        radius: Math.min(width, height) * 0.5
        color: root.pressed ? "#d0d0d0" : "#3b3b3b"
    }
}
