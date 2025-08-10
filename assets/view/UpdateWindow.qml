import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    confirm.text: "Download & Install"

    Connections {
        target: Plugin

        function onOpened(latest, commitsRaw) {
            listRepeater.model = JSON.parse(commitsRaw);
            message.text = `v${Plugin.getPluginVersion()} → ${latest}`;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        Text {
            text: "New version available!"
            font.bold: true
            font.pixelSize: 22
            color: AlgStyle.text.color.normal
            Layout.fillWidth: true
        }

        Text {
            text: "Changelog"
            font.bold: true
            color: AlgStyle.text.color.normal
            Layout.fillWidth: true
        }

        Rectangle {
            id: changelogBackground
            radius: 15
            color: Qt.rgba(0.0, 0.0, 0.0, 0.1)
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                clip: true
                anchors.fill: parent
                anchors.margins: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                ColumnLayout {
                    spacing: 15
                    width: changelogBackground.width - 15

                    Repeater {
                        id: listRepeater

                        property real scopeWidth: 0.0
                        
                        delegate: ColumnLayout {
                            visible: repeater.model.length > 0
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true
                                
                                Rectangle {
                                    radius: 10
                                    color: modelData.color
                                    width: listTitle.implicitWidth + 20
                                    height: listTitle.implicitHeight + 10

                                    Text {
                                        id: listTitle
                                        anchors.centerIn: parent
                                        text: modelData.name
                                        color: AlgStyle.text.color.normal
                                        font.bold: true
                                    }
                                }

                                SPSeparator {
                                    Layout.fillWidth: true
                                }
                            }

                            Repeater {
                                id: repeater
                                model: modelData.commits
                                delegate: RowLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 10
                                    Layout.rightMargin: 20
                                    
                                    property alias authorText: authorText
                                    
                                    SPControl {
                                        id: authorControl
                                        cursorShape: Qt.PointingHandCursor
                                        tooltip.text: "View author"
                                        height: authorText.implicitHeight
                                        Layout.preferredWidth: listRepeater.scopeWidth
                                        
                                        Text {
                                            id: authorText
                                            opacity: 0.75
                                            wrapMode: Text.WordWrap
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            color: authorControl.hovered ? "#e08ee0" : "#6dabf0"
                                            text: modelData.author
                                        }

                                        onClicked: Qt.openUrlExternally(`https://github.com/${modelData.author}`)
                                    }
                                    

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.message
                                        font.pixelSize: 12
                                        wrapMode: Text.WordWrap
                                        horizontalAlignment: Text.AlignLeft
                                        verticalAlignment: Text.AlignVCenter
                                        color: AlgStyle.text.color.normal
                                    }

                                    SPButton {
                                        tooltip.text: "View commit"
                                        icon.source: Plugin.asset("icons/link.png")
                                        implicitWidth: 25
                                        implicitHeight: implicitWidth
                                        icon.width: implicitWidth * 0.6
                                        icon.height: implicitHeight * 0.6
                                        contentAlignment: Qt.AlignCenter

                                        onClicked: Qt.openUrlExternally(`https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/commit/${modelData.sha}`)
                                    }
                                }

                                onItemAdded: (i, item) => listRepeater.scopeWidth = Math.max(listRepeater.scopeWidth, item.authorText.width)
                            }
                        }
                    }
                }
            }
        }
    }
}
