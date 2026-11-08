import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    height: 35
    color: AlgStyle.background.color.mainWindow

    // Painter calls this entry point when opening the shader parameters panel.
    // The parameters themselves are edited in the plugin's dock.
    function displayShaderParameters(shaderId) {}
    
    onHeightChanged: if (height != label.height) height = Qt.binding(() => label.height)

    Text {
        id: label
        width: root.width
        height: 35
        horizontalAlignment: Text.AlignHCenter
        color: AlgStyle.text.color.normal
        textFormat: Text.MarkdownText
        text: "Shader parameters are available in the **CS2 Workshop Tools** menu"
    }
}
