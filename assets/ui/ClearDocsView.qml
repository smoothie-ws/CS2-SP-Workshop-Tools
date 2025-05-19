import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Rectangle {
    id: root
    color: AlgStyle.background.color.mainWindow

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Text {
            Layout.fillHeight: true 
            color: AlgStyle.text.color.normal
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            lineHeight: 1.4
            text: "<p>You are about to remove all the files associated with the plugin.</p><p>Are you sure?</p>"
        }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SPButton {
                text: "ClearDocs"
                backgroundRect.opacity: hovered ? 1.0 : 0.65
                backgroundRect.color: "white"
                label.color: "#262626"
                Layout.alignment: Qt.AlignHCenter

                onClicked: CS2WT.clearDocs(true)
            }

            SPButton {
                text: "Cancel"
                backgroundRect.opacity: hovered ? 0.75 : 0.25
                backgroundRect.color: "black"
                label.color: AlgStyle.text.color.normal
                Layout.alignment: Qt.AlignHCenter

                onClicked: CS2WT.clearDocs(false)
            }
        }
    }
}