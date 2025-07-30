import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import Painter 1.0
import AlgWidgets.Style 2.0
import "./SPWidgets"


SPPopup {
    id: root

    onAccepted: Plugin.startTexturesDecompilation()
    onIgnoreRequested: Plugin.setIgnoreTexturesAreMissing(true)

    property real progress: 0.0
    property string log: "Decompilation started"
    property string decompilationState: "Decompiling"

    content: Rectangle {
        radius: 10
        width: 400
        height: 155
        color: Qt.rgba(0.0, 0.0, 0.0, 0.25)
        
        Text {
            anchors.fill: parent
            anchors.margins: 15
            color: AlgStyle.text.color.normal
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            lineHeight: 1.4
            text: "
                <p>
                    Base weapon textures are required by the shaders to calculate paint wear, dirt, and other effects.
                </p>
                <p>
                    If you have Counter-Strike 2 installed on your computer, you can automatically decompile the textures by clicking <b>\"Decompile now\"</b>.
                </p>
                <p>
                    Otherwise, click <b>\"Dismiss\"</b>. In that case, you will need to provide the textures manually.
                </p>
            "
        }
    }

    Connections {
        target: Plugin

        function onOpened() {
            title = "Missing base weapon textures!";
            ignorable = true;
            acceptButton.text = "Decompile now";
            cancelButton.text = "Dismiss";
            acceptButton.tooltip.text = "Start decompiling now";
            cancelButton.tooltip.text = "Provide the textures later";
        }

        function onDecompilationStarted() {
            title = "Decompiling";
            ignorable = false;
            closable = false;
            acceptable = false;
            cancelable = false;
        }

        function onDecompilationStateChanged(state) {
            root.decompilationState = state;
        }

        function onDecompilationUpdated(progress, weapon) {
            root.progress = progress;
            log += `\nDone: ${weapon}`;
        }

        function onDecompilationFinished() {
            root.close();
        }
    }

}

    SPPopup {
        id: cs2PathIsMissingPopup
        anchors.centerIn: parent

        title: "Counter-Strike 2 path required!"
        acceptButton.text: "Proceed"
        acceptButton.enabled: cs2PathIsValid
        cancelButton.text: "Cancel"
        
        property string cs2Path: ""
        property bool cs2PathIsValid: false

        onCs2PathChanged: cs2PathIsValid = Plugin.valCs2Path(cs2Path)
        onAccepted: Plugin.setCs2Path(cs2Path)

        content: ColumnLayout {
            width: 400
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                height: 115
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)
            
                Text {
                    anchors.fill: parent
                    anchors.margins: 15
                    color: AlgStyle.text.color.normal
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    text: "
                        <p>
                            Counter-Strike 2 path is used to automatically save .econitem files associated with weapon finishes and fast texture exporting.
                        </p>
                        <p>
                            If you have Counter-Strike 2 installed on your computer, you can provide path to its folder location.
                        </p>
                        <p>
                            You can change the path at any time in the plugin settings menu.
                        </p>
                    "
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    color: "transparent"
                    radius: 13.5
                    height: 30
                    border.width: 2
                    border.color: cs2PathIsMissingPopup.cs2PathIsValid ? "transparent" : "red"
                    Layout.fillWidth: true
                    
                    SPTextInput {
                        id: cs2PathInput
                        anchors.fill: parent
                        anchors.margins: parent.border.width + 2
                        text: cs2PathIsMissingPopup.cs2Path

                        onTextEdited: cs2PathIsMissingPopup.cs2Path = text
                    }
                }

                SPButton {
                    id: cs2PathPicker
                    text: "Select folder"
                    
                    onClicked: fileDialog.open()

                    SPFileDialog {
                        id: fileDialog
                        title: "Select folder"
                        selectFolder: true
                        folder: Qt.resolvedUrl(cs2PathIsMissingPopup.cs2Path)

                        onAccepted: {
                            cs2PathInput.text = fileUrl.toString().substring(8);
                            cs2PathInput.textEdited();
                        }
                    }
                }
            }
        }
    }

    SPPopup {
        id: root
        anchors.centerIn: parent

        content: ColumnLayout {
            width: 400
            spacing: 15

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: `${root.decompilationState}...`
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                }

                Label {
                    color: AlgStyle.text.color.normal
                    text: `${parseInt(root.progress * 100)}%`
                }
            }

            Rectangle {
                height: 20
                radius: 10
                Layout.fillWidth: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    width: Math.max(height, root.progress * parent.width)
                    color: AlgStyle.text.color.normal
                }
            }
            
            Rectangle {
                height: 150
                radius: 10
                Layout.fillWidth: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.25)

                ScrollView {
                    anchors.fill: parent
                    clip: true

                    Text {
                        text: root.log
                        color: AlgStyle.text.color.normal
                        anchors.fill: parent
                        anchors.margins: 10
                    }
                }
            }
        }
    }