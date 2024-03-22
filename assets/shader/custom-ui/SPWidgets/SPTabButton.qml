import QtQuick 2.7
import QtQuick.Controls 2.7
import QtQuick.Layouts 1.3

TabButton {
    id: root
    signal selected()

    background: 
        SPRectangle {
            color: "#818181"
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
