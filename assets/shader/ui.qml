import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    height: 35
    color: AlgStyle.background.color.mainWindow
    
    onHeightChanged: if (height != label.height) height = Qt.binding(() => label.height)

    Label {
        id: label
        width: root.width
        height: 35
        horizontalAlignment: Text.AlignHCenter
        color: AlgStyle.text.color.normal
        textFormat: Text.MarkdownText
        text: "Shader parameters are available in the **CS2 Workshop Tools** menu"
    }
}
