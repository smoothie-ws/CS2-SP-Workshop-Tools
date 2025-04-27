import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import Painter 1.0
import AlgWidgets.Style 2.0
import "./SPWidgets"

Rectangle {
    id: root
    color: "#262626"
    layer.enabled: root.busy
    layer.effect: GaussianBlur {
        anchors.fill: root
        source: root
        radius: 8
        samples: 16
    }

    // 0 - closed
    // 1 - regular substance painter project
    // 2 - weapon finish project
    property int projectKind: 0
    readonly property bool busy: texturesAreMissingPopup.opened || cs2PathIsMissingPopup.opened || decompilingProgressPopup.opened
    
    Connections {
        target: internal
        onTexturesAreMissing: texturesAreMissingPopup.open()
        onCs2PathIsMissing: cs2Path => {
            cs2PathIsMissingPopup.cs2Path = cs2Path;
            cs2PathIsMissingPopup.open();
        }
        onDecompilationStarted: decompilingProgressPopup.open()
        onDecompilationStateChanged: state => decompilingProgressPopup.decompilationState = state;
        onDecompilationUpdated: (progress, weapon) => decompilingProgressPopup.update(progress, weapon)
        onDecompilationFinished: decompilingProgressPopup.close()
        onProjectKindChanged: projectKind => {
            root.projectKind = projectKind;
            if (projectKind == 2)
                weaponFinishSettings.connectWeaponFinish(0);
        }
    }

    // main
    ColumnLayout {
        anchors.fill: root
        anchors.margins: 10
        spacing: 10

        // header
        RowLayout {
            id: header
            Layout.fillWidth: true

            SPSeparator { Layout.fillWidth: true }

            SPButton {
                text: "New Weapon Finish"
                tooltip.text: "Create a new project and set it up as Weapon Finish"
                icon.source: "./icons/add.png"
                icon.width: 18
                icon.height: 18
                Layout.alignment: Qt.AlignCenter
                onClicked: {
                    weaponFinishInitWindow.isNew = true;
                    weaponFinishInitWindow.show();
                }
            }
        }

        // main
        Rectangle {
            color: "#333333"
            radius: 10
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                anchors.fill: parent
                clip: true
                
                WeaponFinishSettings {
                    id: weaponFinishSettings
                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.rightMargin: 15
                    enabled: root.projectKind == 2
                }
            }

            ColumnLayout {
                id: placeholder
                anchors.fill: parent
                spacing: 20
                visible: root.projectKind != 2

                Label {
                    text: root.projectKind == 0 ? "No project is opened" : "Opened project is not Weapon Finish"
                    color: AlgStyle.text.color.normal
                    font.pixelSize: 22
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                }
                
                SPButton {
                    text: "Set up as Weapon Finish"
                    visible: root.projectKind == 1
                    tooltip.text: "Set up opened project as Weapon Finish"
                    icon.source: "./icons/setup.png"
                    icon.width: 18
                    icon.height: 18
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                    onClicked: {
                        var screenPosition = parent.mapToGlobal(x, y);
                        weaponFinishInitWindow.isNew = false;
                        weaponFinishInitWindow.x = screenPosition.x;
                        weaponFinishInitWindow.y = screenPosition.y;
                        weaponFinishInitWindow.show();
                    }
                }
            }
        }

        // footer 
        Item {
            id: footer
            Layout.fillWidth: true
            Layout.preferredHeight: 45

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    Layout.fillWidth: true
                }

                Label {
                    id: versionLabel
                    text: `v${internal.pluginVersion()}`
                    color: AlgStyle.text.color.normal
                    opacity: 0.5
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }
    }

    SPDialog {
        id: texturesAreMissingPopup
        anchors.centerIn: parent

        ignorable: true
        title: "Missing base weapon textures!"
        acceptButton.text: "Decompile now"
        rejectButton.text: "Dismiss"
        acceptButton.tooltip.text: "Start decompiling now"
        rejectButton.tooltip.text: "Provide the textures later"

        onAccepted: internal.startTexturesDecompilation()
        onIgnoreRequested: internal.ignoreTexturesAreMissing()

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
                        Base weapon textures are required by the shader to calculate paint wear, dirt, and other effects.
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
    }

    SPDialog {
        id: cs2PathIsMissingPopup
        anchors.centerIn: parent

        title: "Counter-Strike 2 path required!"
        acceptButton.text: "Proceed"
        acceptButton.enabled: cs2PathIsValid
        rejectButton.text: "Cancel"
        
        property string cs2Path: ""
        property bool cs2PathIsValid: false

        onCs2PathChanged: cs2PathIsValid = internal.valCs2Path(cs2Path)

        onAccepted: internal.setCs2Path(cs2Path)

        content: ColumnLayout {
            width: 400
            
            Text {
                color: AlgStyle.text.color.normal
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                Layout.fillWidth: true
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

            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    color: "transparent"
                    radius: 13.5
                    height: 30
                    border.width: 2
                    border.color: cs2PathIsMissingPopup.cs2PathIsValid ? "green" : "red"
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

    SPDialog {
        id: decompilingProgressPopup
        anchors.centerIn: parent

        title: "Decompiling"
        ignorable: false
        closable: false
        acceptable: false
        rejectable: false

        property real progress: 0.0
        property string log: "Decompilation started"
        property string decompilationState: "Decompiling"

        function update(progress, weapon) {
            decompilingProgressPopup.progress = progress;
            log += `\nDone: ${weapon}`;
        }

        content: ColumnLayout {
            width: 400
            spacing: 15

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: `${decompilingProgressPopup.decompilationState}...`
                    color: AlgStyle.text.color.normal
                    Layout.fillWidth: true
                }

                Label {
                    color: AlgStyle.text.color.normal
                    text: `${parseInt(decompilingProgressPopup.progress * 100)}%`
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
                    width: Math.max(height, decompilingProgressPopup.progress * parent.width)
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
                        text: decompilingProgressPopup.log
                        color: AlgStyle.text.color.normal
                        anchors.fill: parent
                        anchors.margins: 10
                    }
                }
            }
        }
    }

    WeaponFinishInitWindow {
        id: weaponFinishInitWindow
    }
}
