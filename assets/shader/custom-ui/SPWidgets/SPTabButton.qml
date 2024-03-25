import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3


TabButton {
    id: root

    signal selected()
    property real contentOpacity: 1.0
    property color backgroundColor: "#252525"
    property color textColor: "#FFFFFF"

    contentItem: 
        RowLayout {
            opacity: root.contentOpacity

            Image {
                visible: root.icon.source != null && root.icon.source != ""
                source: root.icon.source
                Layout.preferredWidth: root.icon.width
                Layout.preferredHeight: root.icon.height
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }

            Label {
                visible: root.label == "" ? false : true
                text: root.label
                color: root.textColor
            }
        }

    background: 
        SPRectangle {
            color: root.backgroundColor
            opacity: root.checked ? 1.0 : 0.0
            radius: 5
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: {
                    root.checked = true
                    root.selected()
                }
            }
        } 
}
