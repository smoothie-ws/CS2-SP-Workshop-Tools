import QtQuick 2.7
import QtQuick.Layouts 1.3

RowLayout {
    id: root
    property alias color: colorPicker.color

    SPButton {
        id: control
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
    }

    SPColorPicker {
        id: colorPicker
    }
}