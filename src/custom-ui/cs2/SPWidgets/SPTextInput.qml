import QtQuick 2.7

TextInput {
    id: root
    color: "#d0d0d0"
    clip: true
    selectionColor: "#1a8dff"
    selectedTextColor: "#fff"
    selectByMouse: true
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    topPadding: padding
    bottomPadding: padding
    leftPadding: padding
    rightPadding: padding

    property real padding: 2.0
    property Component background: Rectangle {
        color: "#282828"
        radius: 15
    }

    onActiveFocusChanged: focus = activeFocus

    Loader {
        z: parent.z - 1
        anchors.fill: parent
        sourceComponent: root.background
    }
}