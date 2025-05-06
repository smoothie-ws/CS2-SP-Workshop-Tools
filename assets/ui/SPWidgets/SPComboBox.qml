import QtQuick 2.15
import QtQuick.Controls 2.0
import AlgWidgets.Style 2.0

ComboBox {
    id: root
    implicitHeight: 25
    textRole: "text"
    valueRole: "value"
    model: {
        const m = [];
        for (const [value, text] of Object.entries(map))
            m.push({value: value, text: text});
        return m;
    }

    property var map: {}
    property var currentKey: null

    Component.onCompleted: {
        if (currentKey != null)
            currentIndex = Object.keys(map).indexOf(currentKey);
        var updating = false;
        function update(f) {
            if (!updating) {
                updating = true;
                f();
                updating = false;
            }
        }
        currentIndexChanged.connect(() =>
            update(() => currentKey = Object.keys(map)[currentIndex])
        );
        currentKeyChanged.connect(() =>
            update(() => currentIndex = Object.keys(map).indexOf(currentKey))
        );
    }

    background: Rectangle {
        anchors.fill: parent
        color: root.hovered ? "#333333" : "#2d2d2d"
        border.color: root.checked ? "#378ef0" : "#4e4e4e"
        border.width: 1
        radius: Math.min(height, width) / 2
    }

    contentItem: Label {
        id: contentLabel
        text: root.displayText
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        leftPadding: 10
        elide: Text.ElideRight
        color: "#cfcfcf"
    }

    indicator: Image {
        visible: root.menu !== null
        source: AlgStyle.icons.combobox.dropArrow
        y: root.topPadding + (root.availableHeight - height) / 2
        anchors.right: parent.right
        anchors.rightMargin: 10
    }
    
    popup: Popup {
        id: popupMenu
        width: root.width
        height: listContent.contentHeight

        background: Rectangle {
            color: "#333333"
            border.color: "#4e4e4e"
            border.width: 1
            radius: Math.min(root.height, root.width) / 2
        }

        ListView {
            id: listContent
            model: root.model
            anchors.fill: parent
            spacing: 5
            clip: true

            ScrollBar.vertical: SPScrollBar {
                visible: parent.height < parent.contentHeight
            }

            delegate: Rectangle {
                id: listItem
                width: listContent.width
                height: 20
                color: listItemMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                radius: 15

                Rectangle {
                    width: 5
                    height: width
                    radius: width
                    x: 5
                    y: parent.height / 2 - height / 2
                    color: root.currentIndex == index ? Qt.rgba(1, 1, 1, 0.75) : Qt.rgba(1, 1, 1, 0.5)
                }

                Label {
                    id: itemLabel
                    x: 15
                    y: parent.height / 2 - height / 2
                    text: root.textRole === '' ? modelData : (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole])
                    font.pixelSize: 11
                    color: root.currentIndex == index ? "#fff" : "#cfcfcf"
                }

                MouseArea {
                    id: listItemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.activated(index)
                        root.currentIndex = index
                        popupMenu.close()
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: (e) => e.accepted = false
        onReleased: (e) => e.accepted = false
        onClicked: (e) => e.accepted = false
        onDoubleClicked: (e) => e.accepted = false
        onPressAndHold: (e) => e.accepted = false
        onWheel: (e) => e.accepted = false
        onPositionChanged: (e) => e.accepted = false
    }
}
