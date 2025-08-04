import QtQuick 2.15
import QtQuick.Layouts 1.3

SPButton {
    id: root
    
    property alias color: colorPicker.color
    property var arrayColor: [color.r, color.g, color.b]

    padding: 1
    background.color: color
    label.text: color
    label.color: (root.color.r + root.color.g + root.color.b) / 3 > 0.5 ? "#000" : "#fff"

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

    onClicked: {
        var screenPosition = parent.mapToGlobal(mouseX, mouseY);
        colorPicker.x = screenPosition.x;
        colorPicker.y = screenPosition.y;
        colorPicker.show();
    }

    SPColorPicker { id: colorPicker }
}
