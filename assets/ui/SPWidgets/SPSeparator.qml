import QtQuick 2.15

Item {
    id: root
    width: axis == SPSeparator.Vertical ? 10 : undefined
    height: axis == SPSeparator.Horizontal ? 10 : undefined

    property int axis: SPSeparator.Horizontal
    property alias color: rect.color

    enum Axis {
        Vertical,
        Horizontal
    }
    
    Rectangle {
        id: rect
        anchors.centerIn: parent
        width: root.axis == SPSeparator.Horizontal ? parent.width : 1
        height: root.axis === SPSeparator.Vertical ? parent.height : 1
        radius: 1
        color: Qt.rgba(1, 1, 1, 0.1)
    }
}
