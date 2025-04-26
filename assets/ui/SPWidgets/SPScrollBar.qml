import QtQuick 2.15
import QtQuick.Controls 2.0
import AlgWidgets.Style 2.0

ScrollBar {
    id: root
    opacity: hovered ? 1.0 : 0.5
    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    background: Rectangle {
        id: backgroundRect
        implicitWidth: 7
        implicitHeight: parent.height
        color: Qt.rgba(0, 0, 0, 0.25)
        radius: width
    }

    contentItem: Rectangle {
        radius: width
        color: Qt.rgba(1, 1, 1, 0.5)
    }
}
