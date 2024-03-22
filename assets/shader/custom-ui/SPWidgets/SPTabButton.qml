import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0


TabButton {
    id: control

    property string icon_source: ""
    property var icon_size: [24, 24]

    property string label

    signal selected

    contentItem: RowLayout {
        Image {
            visible: control.icon_source != null && control.icon_source != ""
            source: control.icon_source
            Layout.preferredWidth: control.icon_size ? control.icon_size[0] : 0
            Layout.preferredHeight: control.icon_size ? control.icon_size[1] : 0
            fillMode: Image.PreserveAspectFit
        }

        Label {
            visible: control.label == "" ? false : true
            text: control.label
            elide: Label.ElideRight
        }
    }

    background: Rectangle {
        color: "#252525"
        opacity: control.checked ? 1.0 : 0.0 
        radius: 5
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            control.checked = true
            control.selected()
        }
    }
}
