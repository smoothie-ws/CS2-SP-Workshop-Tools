import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    confirm.text: "Save"
    option: Row {
        spacing: 10

        Text {
            text: `<style>a:link{color:${hoveredLink ? "#e08ee0" : "#6dabf0"};text-decoration:none;}</style><a href="https://github.com/smoothie-ws/CS2-SP-Workshop-Tools">CS2 Workshop Tools</a> ${Plugin.getPluginVersion()}`
            textFormat: Text.RichText
            color: AlgStyle.text.color.normal
            opacity: 0.75
            anchors.verticalCenter: parent.verticalCenter

            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    QtObject {
        id: internal
        
        property string cs2Path: ""
        property bool cs2PathIsValid: true

        onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : Plugin.valCs2Path(cs2Path)
    }

    function getData() {
        return {
            cs2_path: internal.cs2PathIsValid ? internal.cs2Path : ""
        }
    }

    onOpened: {
        const settings = JSON.parse(Plugin.getPluginSettings());
        if ("cs2_path" in settings)
            internal.cs2Path = settings["cs2_path"];
        if (weaponsRepeater.count === 0)
            weaponsRepeater.model = Object.entries(JSON.parse(Plugin.getWeapons())).map(([id, weapon]) => ({
                weaponId: id, name: weapon.name, uv_scale: weapon.uv_scale
            }));
        else
            weaponsWidgets.refresh();
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            Text {
                text: "CS2 Path"
                font.bold: true
                height: 20
                Layout.fillWidth: true
                color: AlgStyle.text.color.normal
            }
            
            RowLayout {
                Layout.fillWidth: true

                Rectangle {
                    color: "transparent"
                    radius: 13.5
                    height: 30
                    border.width: 2
                    border.color: internal.cs2PathIsValid ? "transparent" : Qt.rgba(0.85, 0.15, 0.15)
                    Layout.fillWidth: true
                    
                    SPTextInput {
                        id: cs2PathInput
                        anchors.fill: parent
                        anchors.margins: parent.border.width + 2
                        text: internal.cs2Path
                        tooltip.text: "CS2 path is used to sync .econitem files and fast texture exporting"

                        onTextEdited: internal.cs2Path = text
                    }
                }

                SPButton {
                    id: cs2PathPicker
                    text: "Select"
                    
                    onClicked: fileDialog.show(internal.cs2Path)

                    SPFileDialog {
                        id: fileDialog
                        title: "Select folder"
                        selectFolder: true

                        onAccepted: {
                            cs2PathInput.text = Plugin.localPath(fileUrl.toString());
                            cs2PathInput.textEdited();
                        }
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                height: 20
                Layout.fillWidth: true

                Text {
                    text: "Weapons"
                    font.bold: true
                    height: 20
                    Layout.fillWidth: true
                    color: AlgStyle.text.color.normal
                }

                SPButton {
                    tooltip.text: "Refresh"
                    implicitWidth: 25
                    implicitHeight: implicitWidth
                    contentAlignment: Qt.AlignCenter
                    icon.source: "./icons/cycle.png"
                    icon.width: implicitWidth * 0.5
                    icon.height: implicitHeight * 0.5

                    onClicked: weaponsWidgets.refresh()
                }
            }

            Rectangle {
                radius: 15
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.1)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    RowLayout {
                        spacing: 10
                        height: 50
                        opacity: 0.5
                        Layout.leftMargin: 5
                        Layout.fillWidth: true
                        
                        SPLabeled {
                            text: "ID"
                            Layout.preferredWidth: 75
                        }
                        
                        SPLabeled {
                            text: "Name"
                            Layout.preferredWidth: 100
                        }

                        SPLabeled {
                            text: "UV Scale"
                            Layout.preferredWidth: 50
                        }

                        Item { Layout.fillWidth: true }
                    }

                    SPSeparator { Layout.fillWidth: true }

                    ScrollView {
                        clip: true
                        Layout.leftMargin: 5
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: weaponsWidgets
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 15

                            function refresh() {
                                for (let i = 0; i < weaponsRepeater.count; ++i) {
                                    const item = weaponsRepeater.itemAt(i);
                                    if (item) item.refresh();
                                }
                            }
                            
                            Repeater {
                                id: weaponsRepeater
                                model: []
                                delegate: Item {
                                    id: weapon
                                    Layout.fillWidth: true
                                    height: 25
                                    
                                    property bool missingTextures: true

                                    function refresh() {
                                        missingTextures = !Plugin.checkWeaponTextures(modelData.weaponId);
                                    }

                                    RowLayout {
                                        spacing: 10
                                        anchors.fill: parent
                                        
                                        Text {
                                            Layout.preferredWidth: 75
                                            text: modelData.weaponId
                                            color: AlgStyle.text.color.normal
                                        }

                                        Text {
                                            Layout.preferredWidth: 100
                                            text: modelData.name
                                            color: AlgStyle.text.color.normal
                                        }

                                        Text {
                                            Layout.preferredWidth: 50
                                            text: modelData.uv_scale.toFixed(3)
                                            color: AlgStyle.text.color.normal
                                        }

                                        Item { Layout.fillWidth: true }

                                        Text {
                                            text: "!"
                                            visible: weapon.missingTextures
                                            font.bold: true
                                            font.pixelSize: 16
                                            color: Qt.rgba(0.85, 0.15, 0.15)
                                            horizontalAlignment: Text.AlignRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                onItemAdded: (i, item) => {
                                    item.refresh();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
