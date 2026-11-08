import QtQuick 2.15
import QtQuick.Layouts 1.3

ColumnLayout {
    id: root

    required property string text

    property alias checked: toggler.checked

    SPButton {
        id: toggler
        checkable: true
        text: `Use ${root.text}`
        tooltip.text: `Whether to ${text.toLowerCase()}`
        Layout.fillWidth: true
    }
}
