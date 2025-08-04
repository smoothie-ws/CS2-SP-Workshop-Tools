import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0

Item {
    id: root
    visible: isOpen
    width: popup.width
    height: popup.height

    property alias isOpen: popup.opened
    property alias icon: popupIcon
    property alias title: popupTitle.text
    property alias ignoreButton: ignoreButton
    property alias acceptButton: acceptButton
    property alias cancelButton: cancelButton

    property alias ignorable: ignoreButton.visible
    property alias closable: closeButton.visible
    property alias acceptable: acceptButton.visible
    property alias cancelable: cancelButton.visible

    property alias content: contentLoader.sourceComponent

    signal opened()
    signal accepted()
    signal cancelled()
    signal ignoreRequested()

    function open() { popup.open(); }
    function close() { popup.close(); }

    function submit(accept) {
        if (ignoreButton.checked)
            ignoreRequested();
        if (accept)
            accepted();
        else 
            cancelled();
        close();
    }

    Popup {
        id: popup
        width: Math.max(header.implicitWidth, Math.max(content.width, footer.implicitWidth))
        height: header.implicitHeight + content.height + footer.implicitHeight
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        onOpened: root.opened()

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

                Text {
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
                        background.opacity: 0.0
                        contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                    }
                }

                SPButton {
                    id: acceptButton
                    text: "OK"
                    background.opacity: hovered ? 1.0 : 0.65
                    background.color: "white"
                    label.color: "#262626"
                    Layout.alignment: Qt.AlignHCenter

                    onClicked: root.submit(true)
                }

                SPButton {
                    id: cancelButton
                    text: "Cancel"
                    background.opacity: hovered ? 0.75 : 0.25
                    background.color: "black"
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
}
