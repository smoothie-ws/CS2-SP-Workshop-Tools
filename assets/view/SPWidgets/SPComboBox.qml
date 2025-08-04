import QtQuick 2.15
import QtQuick.Controls 2.0
import AlgWidgets.Style 2.0

SPControl {
    id: root
    implicitHeight: 25
    cursorShape: Qt.PointingHandCursor

    property var map: {}
    property var currentKey: null
    property alias comboBox: comboBox
    property alias currentIndex: comboBox.currentIndex

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

        comboBox.syncModel();
        mapChanged.connect(comboBox.syncModel);
    }

    ComboBox {
        id: comboBox
        textRole: "text"
        valueRole: "value"
        anchors.fill: parent

        function syncModel() {
            if (!root.map || typeof root.map !== "object")
                return;
            const m = [];
            for (const [value, text] of Object.entries(root.map))
                m.push({value: value, text: text});
            model = m;
        }

        background: Rectangle {
            anchors.fill: parent
            color: root.hovered ? Qt.rgba(0, 0, 0, 0.75) : Qt.rgba(0, 0, 0, 0.25)
            radius: Math.min(height, width) * 0.5
            
            Behavior on color {
                ColorAnimation { duration: 250 }
            }
        }

        contentItem: Label {
            text: comboBox.displayText
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

                    Label {
                        id: itemLabel
                        x: 10
                        y: (parent.height - height) * 0.5
                        text: comboBox.textRole === '' ? modelData : (Array.isArray(comboBox.model) ? modelData[comboBox.textRole] : model[comboBox.textRole])
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
