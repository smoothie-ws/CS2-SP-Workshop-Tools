import QtQuick 2.15
import QtQuick.Layouts 1.3

SPButton {
    id: root
    
    property alias color: colorPicker.color
    property var arrayColor: [color.r, color.g, color.b]

    QtObject {
        id: internal

        property bool updating: false

        function update(f) {
            if (!updating) {
                updating = true;
                f();
                updating = false;
            }
        }
    }
    
    onArrayColorChanged: internal.update(() => {
        color.r = arrayColor[0];
        color.g = arrayColor[1];
        color.b = arrayColor[2];
    })

    onColorChanged: internal.update(() => {
        arrayColor = [
            color.r, 
            color.g, 
            color.b
        ];
    })
    Layout.fillWidth: true

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            mouse.accepted = false;
        }
    }

    onClicked: {
        var screenPosition = parent.mapToGlobal(mouseArea.mouseX, mouseArea.mouseY);
        colorPicker.x = screenPosition.x;
        colorPicker.y = screenPosition.y;
        colorPicker.show();
    }

    Rectangle {
        id: previewArea
        anchors.fill: parent
        radius: 15
        border.color: "#454545"
        border.width: 2
        color: root.color
    }

    contentItem: Text {
        text: root.color
        color: (root.color.r + root.color.g + root.color.b) / 3 > 0.5 ? "#000" : "#fff"
    }

    SPColorPicker {
        id: colorPicker
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: (e) => e.accepted = false
        onReleased: (e) => e.accepted = false
        onClicked: (e) => e.accepted = false
        onDoubleClicked: (e) => e.accepted = false
        onPressAndHold: (e) => e.accepted = false
        onWheel: (e) => e.accepted = false
        onPositionChanged: (e) => e.accepted = false
    }
}
