import QtQuick 2.15
import QtQuick.Layouts 1.3
import AlgWidgets 2.0

ColumnLayout {
    id: root

    required property string text

    property alias checked: toggler.checked
    property alias url: picker.url

    SPButton {
        id: toggler
        checkable: true
        text: `Use ${root.text}`
        tooltip.text: `Whether to ${text.toLowerCase()}`
        Layout.fillWidth: true
    }
    
    SPLabeled {
        text: root.text
        visible: root.checked && externMode.checked

        SPResourcePicker {
            id: picker
            Layout.fillWidth: true
            filters: AlgResourcePicker.TEXTURE
        }
    }
}
