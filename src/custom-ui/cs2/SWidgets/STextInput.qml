import QtQuick 2.7

TextInput {
    id: root
    color: "#d0d0d0"
    selectionColor: "#1a8dff"
    selectedTextColor: "#fff"
    selectByMouse: true
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    topPadding: 2
    bottomPadding: 2
    leftPadding: 2
    rightPadding: 2

    Rectangle {
        id: background
        z: parent.z - 1
        anchors.fill: parent
        color: "#2d2d2d"
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1
        radius: 5
    }

    onActiveFocusChanged: {
        focus = activeFocus;
    }
}