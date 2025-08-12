import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    confirm.text: "Download & Install"
    option: Item {
        Connections {
            target: Plugin

            function onOpened(latest, commitsRaw) {
                ignoreButton.checked = !Plugin.getCheckForUpdates();
                listRepeater.model = JSON.parse(commitsRaw);
                changelogLabel.latest = latest;
            }
        }

        SPButton {
            id: ignoreButton
            width: implicitWidth + 10
            text: "Don't show again"
            background.color: hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
            label.horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                Plugin.setCheckForUpdates(checked);
                checked = !checked;
            }

            Rectangle {
                x: 5
                width: 15
                height: width
                radius: width
                border.width: 2.5
                border.color: "#1f1f1f"
                anchors.verticalCenter: parent.verticalCenter
                color: ignoreButton.checked ? "#b3b3b3" : "#1f1f1f"

                Behavior on color {
                    ColorAnimation { duration: 50 }
                }
            }
        }
    }

    SPPopup {
        id: downloadingPopup
        anchors.centerIn: parent
        title: "Downloading"
        ignorable: false
        closable: false
        acceptable: false
        cancelable: false

        property real progress: 0.0
        property string log: ""
        property string currentState: "Downloading"

        onOpened: {
            progress = 0.0;
            log = "";
            currentState = "Downloading";
        }

        Connections {
            target: Plugin

            function onDownloadingStarted() {
                downloadingPopup.open();
                onDownloadingUpdated(0.0)
            }

            function onDownloadingStateChanged(state) {
                downloadingPopup.currentState = state;
            }

            function onDownloadingUpdated(progress) {
                downloadingPopup.progress = progress;
            }

            function onDownloadingFinished() {
                downloadingPopup.close();
            }
        }
        
        content: ColumnLayout {
            width: 400
            spacing: 15

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: `${downloadingPopup.currentState}...`
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                }

                Text {
                    color: AlgStyle.text.color.normal
                    text: `${parseInt(downloadingPopup.progress * 100)}%`
                }
            }

            Rectangle {
                height: 10
                radius: 15
                Layout.fillWidth: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: Math.max(height, downloadingPopup.progress * parent.width)
                    color: AlgStyle.text.color.normal
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        
        Row {
            spacing: 15

            Image {
                source: Plugin.asset("icons/arrow.png")
                opacity: 0.75
                mipmap: true
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: "New version available!"
                font.bold: true
                font.pixelSize: 22
                color: AlgStyle.text.color.normal
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        RowLayout {
            id: changelogLabel

            property string latest: ""
            property string link: ""

            Text {
                id: versionLabel
                textFormat: Text.RichText
                text: `<b>${Plugin.getPluginVersion()}</b> → <b>${changelogLabel.latest}</b> Changelog`
                font.pixelSize: 12
                color: AlgStyle.text.color.normal
                Layout.fillWidth: true
            }

            SPButton {
                text: "View on GitHub"
                icon.source: Plugin.asset("icons/github.png")
                icon.width: 20
                icon.height: 20

                onClicked: Qt.openUrlExternally("https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/releases/latest")
            }
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
                leftPadding: 10
                topPadding: 10
                rightPadding: 10
                bottomPadding: 10
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                
                ColumnLayout {
                    spacing: 10
                    width: changelogBackground.width - 15

                    Repeater {
                        id: listRepeater

                        property real scopeWidth: 0.0
                        
                        delegate: SPGroup {
                            radius: 10
                            text: modelData.name
                            visible: repeater.model.length > 0
                            scopeWidth: 0.0
                            Layout.fillWidth: true
                            Layout.rightMargin: 5
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: modelData.color }
                                GradientStop { position: 1.0; color: toggled ? "transparent" : modelData.color }
                            }

                            Repeater {
                                id: repeater
                                model: modelData.commits
                                delegate: ColumnLayout {
                                    Layout.fillWidth: true

                                    RowLayout {
                                        spacing: 15
                                        Layout.fillWidth: true

                                        SPButton {
                                            tooltip.text: `View commit #${modelData.sha}`
                                            icon.source: Plugin.asset("icons/link.png")
                                            implicitWidth: 25
                                            implicitHeight: implicitWidth
                                            icon.width: implicitWidth * 0.6
                                            icon.height: implicitHeight * 0.6
                                            label.font.pixelSize: 10
                                            contentAlignment: Qt.AlignCenter

                                            onClicked: Qt.openUrlExternally(`https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/commit/${modelData.sha}`)
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.message
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignLeft
                                            verticalAlignment: Text.AlignVCenter
                                            wrapMode: Text.WordWrap
                                            color: AlgStyle.text.color.normal
                                        }
                                    }

                                    RowLayout {
                                        spacing: 5
                                        opacity: 0.5
                                        Layout.fillWidth: true
                
                                        SPControl {
                                            tooltip.x: 0.0
                                            cursorShape: Qt.PointingHandCursor
                                            implicitWidth: shaText.implicitWidth
                                            implicitHeight: shaText.implicitHeight
                                            Layout.fillWidth: true

                                            TextEdit{
                                                id: textEdit
                                                text: modelData.sha
                                                visible: false
                                            }

                                            Text {
                                                id: shaText
                                                text: `#${modelData.sha.substring(0, 7)}`
                                                color: "#9bc8ff"
                                            }

                                            onHoveredChanged: {
                                                if (hovered) {
                                                    tooltip.text = `Copy SHA ${modelData.sha}`;
                                                    shaText.color = "#df9bff";
                                                } else 
                                                    shaText.color = "#9bc8ff";
                                            }

                                            onClicked: {
                                                textEdit.selectAll();
                                                textEdit.copy();
                                                tooltip.text = "Copied!";
                                            }
                                        }

                                        Text {
                                            text: "by"
                                            color: AlgStyle.text.color.normal
                                        }

                                        SPControl {
                                            cursorShape: Qt.PointingHandCursor
                                            tooltip.text: "View author"
                                            implicitWidth: authorText.implicitWidth
                                            implicitHeight: authorText.implicitHeight

                                            Text {
                                                id: authorText
                                                text: modelData.author
                                                color: "#9bc8ff"
                                            }

                                            onHoveredChanged: {
                                                if (hovered)
                                                    authorText.color = "#df9bff";
                                                else 
                                                    authorText.color = "#9bc8ff";
                                            }

                                            onClicked: Qt.openUrlExternally(`https://github.com/${modelData.author}`)
                                        }

                                        Text {
                                            text: `on ${modelData.date}`
                                            color: AlgStyle.text.color.normal
                                            visible: modelData.date !== undefined && modelData.date !== null
                                        }
                                    }

                                    SPSeparator {
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
