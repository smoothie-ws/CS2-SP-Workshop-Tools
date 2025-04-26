import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

ColumnLayout {
    id: root
    opacity: enabled ? 1.0 : 0.5
    spacing: 7

    property var labels: []
    property alias background: loader.sourceComponent

    Loader {
        id: loader
        width: root.width
        height: root.height
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
                    color: groupButton.toggled ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(1, 1, 1, 0.05) 
                }
            }
        }
    }

    default property alias children: content.children
    property alias activeScopeBorder: scopeLine.visible
    property alias toggled: groupButton.toggled
    property alias expandable: groupButton.visible
    property alias text: groupButton.text
    property alias tooltip: groupButton.tooltip
    property real padding: 5

    AlgToggleButton {
        id: groupButton
        toggled: true
        Layout.fillWidth: true
        Layout.margins: root.padding
        textAlignment: Text.AlignLeft
        __style: AlgStyle.widget.groupWidget
        iconName: checked ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed
        iconSize: AlgStyle.widget.groupWidget.iconSize
    }

    RowLayout {
        id: mainLayout
        Layout.fillWidth: true
        Layout.margins: root.padding
        Layout.topMargin: groupButton.visible ? 0 : root.padding
        visible: groupButton.toggled

        Item {
            id: scopeLine
            visible: true
            Layout.fillHeight: true
            Layout.preferredWidth: 15
        }

        ColumnLayout {
            id: content
            Layout.fillWidth: true
        }
    }
}
