import QtQuick 2.15

TextInput {
    id: root
    color: "#d0d0d0"
    clip: true
    padding: 5
    selectionColor: "#1a8dff"
    selectedTextColor: "#fff"
    selectByMouse: true
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    property Component background: Rectangle {
        color: "black"
        radius: 10
        opacity: root.focus ? 0.5 : (mouseArea.hovered ? 0.3 : 0.15)

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    onActiveFocusChanged: focus = activeFocus

    Loader {
        z: parent.z - 1
        anchors.fill: parent
        sourceComponent: root.background
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        hoverEnabled: true

        property bool hovered: false

        onEntered: hovered = true
        onExited: hovered = false
        onPressed: (e) => e.accepted = false
        onReleased: (e) => e.accepted = false
        onClicked: (e) => e.accepted = false
        onDoubleClicked: (e) => e.accepted = false
        onPressAndHold: (e) => e.accepted = false
        onWheel: (e) => e.accepted = false
        onPositionChanged: (e) => e.accepted = false
    }
}