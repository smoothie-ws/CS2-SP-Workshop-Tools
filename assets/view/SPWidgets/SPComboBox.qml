import QtQuick 2.15
import QtQuick.Controls 2.0
import AlgWidgets.Style 2.0

SPControl {
    id: root
    implicitHeight: 25
    cursorShape: Qt.PointingHandCursor

    property var map: {}
    property var currentKey: null
    property alias model: comboBox.model
    property alias currentValue: comboBox.currentValue
    property alias currentIndex: comboBox.currentIndex

    QtObject {
        id: internal
        property bool ready: false
        property bool syncing: false

        function sync(f) {
            if (syncing) return;
            syncing = true;
            try { f(); } finally { syncing = false; }
        }
    }

    Component.onCompleted: {
        internal.ready = true;
        comboBox.syncModel();
    }
    onMapChanged: if (internal.ready) comboBox.syncModel()
    onCurrentIndexChanged: if (internal.ready) internal.sync(() => {
        const keys = Object.keys(map || {});
        currentKey = currentIndex >= 0 && currentIndex < keys.length ? keys[currentIndex] : null;
    })
    onCurrentKeyChanged: if (internal.ready) internal.sync(() => {
        currentIndex = Object.keys(map || {}).indexOf(String(currentKey));
    })

    onWheel: e => {
        const count = comboBox.count;
        if (count > 0)
            currentIndex = (count + currentIndex - Math.floor(e.angleDelta.y / 120)) % count;
    }

    ComboBox {
        id: comboBox
        textRole: "text"
        valueRole: "value"
        anchors.fill: parent

        function syncModel() {
            internal.sync(() => {
                const previousKey = root.currentKey;
                const entries = Object.entries(root.map || {});
                model = entries.map(entry => ({value: entry[0], text: entry[1]}));
                currentIndex = previousKey === null || previousKey === undefined
                    ? (entries.length > 0 ? 0 : -1)
                    : entries.findIndex(entry => entry[0] === String(previousKey));
                root.currentKey = currentIndex >= 0 ? entries[currentIndex][0] : null;
            });
        }

        background: Rectangle {
            anchors.fill: parent
            color: root.hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)
            radius: Math.min(height, width) * 0.5
            
            Behavior on color {
                ColorAnimation { duration: 250 }
            }
        }

        contentItem: Text {
            text: comboBox.displayText || ""
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            leftPadding: 10
            color: "#cfcfcf"
        }

        indicator: Image {
            visible: comboBox.menu !== null
            source: comboBox.down ? AlgStyle.icons.groupwidget.expanded : AlgStyle.icons.groupwidget.collapsed
            y: comboBox.topPadding + (comboBox.availableHeight - height) * 0.5
            anchors.right: parent.right
            anchors.rightMargin: 10
        }
        
        popup: Popup {
            id: popup
            y: comboBox.height + 5
            width: comboBox.width
            height: Math.min(listContent.contentHeight, 200)

            background: Rectangle {
                color: "#262626"
                radius: Math.min(comboBox.height, comboBox.width) * 0.5
            }

            ListView {
                id: listContent
                model: comboBox.model
                anchors.fill: parent
                spacing: 5
                clip: true

                ScrollBar.vertical: SPScrollBar {
                    visible: parent.height < parent.contentHeight
                }

                delegate: Rectangle {
                    id: listItem
                    width: listContent.width - 15
                    height: 25
                    color: listItemMouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    radius: Math.min(comboBox.height, comboBox.width) * 0.5

                    Behavior on color {
                        ColorAnimation { duration: 250 }
                    }

                    Text {
                        id: itemLabel
                        x: 10
                        y: (parent.height - height) * 0.5
                        text: modelData && modelData.text !== undefined ? modelData.text : ""
                        font.pixelSize: 11
                        color: comboBox.currentIndex === index ? "#fff" : "#cfcfcf"
                    }

                    MouseArea {
                        id: listItemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            comboBox.activated(index)
                            comboBox.currentIndex = index
                            popup.close()
                        }
                    }
                }
            }
        }
    }
}
