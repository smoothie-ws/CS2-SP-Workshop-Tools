import QtQuick 2.7
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import QtQuick.Dialogs 1.3

RowLayout {
    id: root
    property alias arrayColor: colorPicker.arrayColor

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
            colorPicker.show(screenPosition);
        }

        Rectangle {
            id: previewArea
            anchors.fill: parent
            radius: 5
            border.color: "#454545"
            border.width: 2
            color: colorPicker.color
        }

        contentItem: Text {
            text: colorPicker.color.toString().toUpperCase()
            color: (arrayColor[0] + arrayColor[1] + arrayColor[2]) / 3 > 0.5 ? "#000" : "#fff"
        }
    }

    // AlgColorPicker {
    //     id: colorPicker
    //     linearMode: true
    //     property var arrayColor: []

    //     Component.onCompleted: {
    //         color = (Qt.rgba(arrayColor[0], arrayColor[1], arrayColor[2], 1))
    //     }

    //     onArrayColorChanged: {
    //         color = Qt.rgba(arrayColor[0], arrayColor[1], arrayColor[2]);
    //     }

    //     onColorChanged: {
    //         arrayColor = [color.r, color.g, color.b];
    //     }
    // }
}
