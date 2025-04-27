import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import AlgWidgets.Style 2.0

Item {
    id: root
    visible: opened
    width: popup.width
    height: popup.height

    property alias opened: popup.opened
    property alias icon: popupIcon
    property alias title: popupTitle.text
    property alias ignoreButton: ignoreButton
    property alias acceptButton: acceptButton
    property alias rejectButton: rejectButton

    property alias ignorable: ignoreButton.visible
    property alias closable: closeButton.visible
    property alias acceptable: acceptButton.visible
    property alias rejectable: rejectButton.visible

    property Component content: null

    signal accepted()
    signal rejected()
    signal ignoreRequested()

    function open() { popup.open(); }
    function close() { popup.close(); }

    function submit(accept) {
        if (ignoreButton.checked)
            ignoreRequested();
        if (accept)
            accepted();
        else 
            rejected();
        close();
    }

    Popup {
        id: popup
        width: Math.max(header.implicitWidth, Math.max(content.width, footer.implicitWidth))
        height: header.implicitHeight + content.height + footer.implicitHeight
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            anchors.fill: parent
            spacing: 15

            RowLayout {
                id: header
                spacing: 15
                height: Math.max(popupIcon.paintedHeight, popupTitle.implicitHeight)
                Layout.fillWidth: true

                Item {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28

                    Image {
                        id: popupIcon
                        anchors.fill: parent
                        source: "./icons/warning.png"
                        mipmap: true
                    }
                }

                Label {
                    id: popupTitle
                    color: AlgStyle.text.color.normal
                    font.pixelSize: 13
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                }

                SPButton {
                    id: closeButton
                    visible: root.closable
                    implicitWidth: 25
                    implicitHeight: implicitWidth
                    tooltip.text: "Close"
                    icon.source: "./icons/close.png"
                    icon.width: 12
                    icon.height: 12

                    onClicked: root.submit(false)
                }
            }

            Loader {
                id: contentLoader
                Layout.fillWidth: true
                sourceComponent: root.content
            }

            RowLayout {
                id: footer
                Layout.fillWidth: true

                Item { 
                    Layout.fillWidth: true

                    SPButton {
                        id: ignoreButton
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.ignorable
                        checkable: true
                        text: "Don't show again"
                        Layout.fillWidth: true
                        backgroundRect.opacity: 0.0
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                }

                SPButton {
                    id: acceptButton
                    text: "OK"
                    backgroundRect.opacity: hovered ? 1.0 : 0.65
                    backgroundRect.color: "white"
                    label.color: "#262626"
                    Layout.alignment: Qt.AlignHCenter

                    onClicked: root.submit(true)
                }

                SPButton {
                    id: rejectButton
                    text: "Cancel"
                    backgroundRect.opacity: hovered ? 0.75 : 0.25
                    backgroundRect.color: "black"
                    label.color: AlgStyle.text.color.normal
                    Layout.alignment: Qt.AlignHCenter

                    onClicked: root.submit(false)
                }
            }
        }

        background: Rectangle {
            radius: 10
            color: AlgStyle.background.color.mainWindow
        }
    }
    
    DropShadow {
        source: popup
        anchors.fill: root
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        anchors.topMargin: 15
        anchors.bottomMargin: 5
        transparentBorder: true
        verticalOffset: 10
        radius: 16.0
        samples: 8
        color: Qt.rgba(0.0, 0.0, 0.0, 0.25)
    }
}
