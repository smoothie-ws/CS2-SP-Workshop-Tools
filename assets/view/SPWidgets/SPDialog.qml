import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow

    default property alias data: content.data
    property alias option: optionLoader.sourceComponent
    property alias confirm: confirmButton
    property alias cancel: cancelButton
    
    signal opened()
    signal closed()

    Connections {
        target: Plugin

        function onOpened() { 
            root.opened();
        }

        function onClosed() { 
            root.closed();
        }
    }

    // to override
    function getData() {
        return {};
    }

    ColumnLayout {
        spacing: 25
        anchors.fill: parent
        anchors.margins: 20
        
        Item {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.fillWidth: true
            
            Loader {
                id: optionLoader
                Layout.fillWidth: true
            }

            SPButton {
                id: confirmButton
                text: "Proceed"
                background.color: hovered ? Qt.rgba(1, 1, 1, 1.0) : Qt.rgba(1, 1, 1, 0.65)
                label.color: "#262626"
                Layout.alignment: Qt.AlignHCenter

                onClicked: Plugin.confirm(JSON.stringify(root.getData()))
            }

            SPButton {
                id: cancelButton
                text: "Close"
                background.color: hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)
                label.color: AlgStyle.text.color.normal
                Layout.alignment: Qt.AlignHCenter

                onClicked: Plugin.close()
            }
        }
    }
}
