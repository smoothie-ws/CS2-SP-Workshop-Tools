import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    id: root
    opacity: enabled ? 1.0 : 0.5
    spacing: 7

    default property alias children: content.children
    property alias activeScopeBorder: scopeLine.visible
    property alias toggled: groupButton.checked
    property alias text: groupButton.text
    property alias tooltip: groupButton.tooltip
    property alias expandable: groupButton.enabled
    property real padding: 5

    property var labels: []
    property alias background: loader.sourceComponent
    property real scopeWidth: 0.0

    Loader {
        id: loader
        width: parent.width
        height: parent.height
        sourceComponent: Rectangle {
            radius: 10
            clip: true
            gradient: Gradient {
                GradientStop { 
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0.05) 
                }
                GradientStop { 
                    position: 1.0
                    color: root.toggled ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(1, 1, 1, 0.05) 
                }
            }
        }
    }
    
    SPButton {
        id: groupButton
        checkable: true
        checked: enabled ? checked : true
        opacity: 1.0
        checker.visible: false
        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
        Layout.fillWidth: true
        Layout.margins: root.padding
        backgroundRect.opacity: 0.0
        label.font.bold: true
        icon.source: enabled ? (checked ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed) : ""
        icon.width: 16
        icon.height: 16
    }

    RowLayout {
        id: mainLayout
        Layout.fillWidth: true
        Layout.margins: root.padding
        Layout.topMargin: groupButton.visible ? 0 : root.padding
        visible: root.toggled

        Item {
            id: scopeLine
            visible: true
            width: 15
            Layout.fillHeight: true
            Layout.preferredWidth: width
        }

        ColumnLayout {
            id: content
            Layout.fillWidth: true
        }
    }
}
