import QtQuick 2.7

TextInput {
    id: root
    color: "#fff"
    selectionColor: "#4f81b3"
    selectedTextColor: "#fff"
    selectByMouse: true
    clip: true
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: 14

    Rectangle {
        id: background
        z: parent.z - 1
        anchors.fill: parent
        color: "#212121"
        border.color: "#616161"
        opacity: 1.0
        border.width: 1
        radius: 5
    }

    onTextChanged: {
      background.border.color = "#4f81b3"
    }
}