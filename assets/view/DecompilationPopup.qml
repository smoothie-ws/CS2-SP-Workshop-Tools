import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPPopup {
    id: root
    anchors.centerIn: parent
    title: "Decompiling"
    ignorable: false
    closable: false
    acceptable: false
    cancelable: false

    property real progress: 0.0
    property string log: ""
    property string currentState: "Decompiling"

    onOpened: {
        progress = 0.0;
        log = "";
        currentState = "Decompiling";
    }

    content: ColumnLayout {
        width: 400
        spacing: 15

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: `${root.currentState}...`
                color: AlgStyle.text.color.normal
                Layout.fillWidth: true
            }

            Text {
                color: AlgStyle.text.color.normal
                text: `${parseInt(root.progress * 100)}%`
            }
        }

        Rectangle {
            height: 10
            radius: 15
            Layout.fillWidth: true
            color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: Math.max(height, root.progress * parent.width)
                color: AlgStyle.text.color.normal
            }
        }
        
        Rectangle {
            height: 100
            radius: 15
            Layout.fillWidth: true
            color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

            ScrollView {
                anchors.fill: parent
                clip: true

                Text {
                    text: root.log
                    color: AlgStyle.text.color.normal
                    anchors.fill: parent
                    anchors.margins: 10
                }
            }
        }
    }
}
