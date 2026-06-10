import QtQuick 2.15
import QtQuick.Layouts 1.3
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

Rectangle {
    id: root
    radius: 15
    implicitHeight: layout.implicitHeight
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
        GradientStop { position: 1.0; color: root.toggled ? Qt.rgba(0, 0, 0, 0) : Qt.rgba(1, 1, 1, 0.05) }
    }
    
    default property alias children: content.children
    property alias content: content
    property alias spacing: content.spacing
    property alias header: header.sourceComponent
    property alias toggled: groupButton.checked
    property alias text: groupButton.text
    property alias tooltip: groupButton.tooltip
    property alias expandable: groupButton.enabled
    property alias scopeWidth: scopeLine.width
    property alias activeScopeBorder: scopeLine.visible
    property real padding: 10

    property var labels: []

    Behavior on implicitHeight {
        NumberAnimation { 
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    ColumnLayout {
        id: layout
        spacing: 7
        width: parent.width

        SPButton {
            id: groupButton
            checkable: true
            checked: true
            checker.visible: false
            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
            Layout.margins: 5
            background.opacity: 0.0
            label.font.bold: true
            icon.source: enabled ? (checked ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed) : ""
            icon.width: 16
            icon.height: 16

            Loader {
                id: header
                anchors.fill: parent
            }
        }

        RowLayout {
            id: mainLayout
            visible: root.toggled
            Layout.fillWidth: true
            Layout.margins: root.padding
            Layout.topMargin: groupButton.visible ? 0 : root.padding

            onVisibleChanged: opacity = visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }

            Item {
                id: scopeLine
                width: 10
                Layout.fillHeight: true
                Layout.preferredWidth: width
            }

            ColumnLayout {
                id: content
                Layout.fillWidth: true
            }
        }
    }
}
