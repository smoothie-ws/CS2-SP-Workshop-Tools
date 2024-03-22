import QtQuick 2.7

Item {
    id: root
    property color color: "white"
    property real radius: 0

    Rectangle {
        id: roundRect
        radius: root.radius
        color: root.color
        anchors.fill: parent
    }

    Rectangle {
        id: squareRect
        anchors.bottom: roundRect.bottom
        anchors.right: roundRect.right
        anchors.top: roundRect.top
        
        color: root.color
        width: roundRect.radius
    }
}
