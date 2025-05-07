import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Window {
    id: root
    minimumWidth: 500
    minimumHeight: 500
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowSystemMenuHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    title: "CS2 Workshop Tools Settings"
    color: AlgStyle.background.color.mainWindow

    property string cs2Path: ""

    property var weaponList: []

    property bool cs2PathIsValid: true
    property bool weaponIsValid: false

    onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : internal.valCs2Path(cs2Path)

    function open() {
        cs2Path = internal.getCs2Path();
        const m = [];
        for (const [value, text] of Object.entries(JSON.parse(internal.getWeaponList())))
            m.push({value: value, text: text});
        weaponList = m;
        ignoreTexturesAreMissing.checked = internal.getIgnoreTexturesMissing();
        show();
    }

    function save() {
        const weapon_list = {};
        for (const weapon of weaponList)
            weapon_list[weapon.value] = weapon.text;
        internal.savePluginSettings(JSON.stringify({
            cs2_path: cs2Path,
            weapon_list: weapon_list,
            ignore_textures_are_missing: ignoreTexturesAreMissing.checked
        }));
        close();
    }

    function valWeapon() {
        const id = weaponIdInput.text.trim();
        const name = weaponNameInput.text.trim();
        let exists = false;
        for (const weapon of root.weaponList)
            if (weapon.value == id || weapon.text == name) {
                exists = true;
                break;
            }
        weaponIsValid = id != "" && name != "" && !exists;
    }

    function addWeapon() {
        root.weaponList = [{
            value: weaponIdInput.text.trim(),
            text: weaponNameInput.text.trim()
        }].concat(root.weaponList);
        weaponIdInput.text = "";
        weaponNameInput.text = "";
        weaponIsValid = false;
    }

    ColumnLayout {
        spacing: 25
        anchors.fill: parent
        anchors.margins: 20
        
        ColumnLayout {
            spacing: 15
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
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
                    border.color: root.cs2PathIsValid ? "green" : "red"
                    Layout.fillWidth: true
                    
                    SPTextInput {
                        id: cs2PathInput
                        anchors.fill: parent
                        anchors.margins: parent.border.width + 2
                        text: root.cs2Path

                        onTextEdited: root.cs2Path = text
                    }
                }

                SPButton {
                    id: cs2PathPicker
                    text: "Select"
                    
                    onClicked: fileDialog.open()

                    SPFileDialog {
                        id: fileDialog
                        title: "Select folder"
                        selectFolder: true
                        folder: Qt.resolvedUrl(root.cs2Path)

                        onAccepted: {
                            cs2PathInput.text = fileUrl.toString().substring(8);
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

            Label {
                text: "Weapons"
                font.bold: true
                height: 20
                Layout.fillWidth: true
                color: AlgStyle.text.color.normal
            }

            Rectangle {
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.1)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    RowLayout {
                        spacing: 10
                        height: 50
                        Layout.fillWidth: true
                        
                        SPLabeled {
                            text: "ID:"

                            SPTextInput {
                                id: weaponIdInput
                                Layout.preferredWidth: 75
                                text: modelData.value
                                tooltip.text: "Weapon Identifier"

                                onTextEdited: root.valWeapon()
                            }
                        }
                        
                        SPLabeled {
                            text: "Name:"

                            SPTextInput {
                                id: weaponNameInput
                                Layout.preferredWidth: 100
                                text: modelData.text
                                tooltip.text: "Weapon Name"

                                onTextEdited: root.valWeapon()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        SPButton {
                            text: "Add"
                            tooltip.text: "Add new weapon"
                            enabled: root.weaponIsValid

                            onClicked: root.addWeapon()
                        }
                    }

                    SPSeparator { Layout.fillWidth: true }

                    ScrollView {
                        clip: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            id: weaponListLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.rightMargin: 15

                            Repeater {
                                model: root.weaponList
                                delegate: Item {
                                    Layout.fillWidth: true
                                    height: 25

                                    RowLayout {
                                        spacing: 10
                                        anchors.fill: parent

                                        SPLabeled {
                                            text: "ID:"
                                            label.opacity: 0.5

                                            Label {
                                                Layout.preferredWidth: 75
                                                text: modelData.value
                                                color: AlgStyle.text.color.normal
                                            }
                                        }
                                        
                                        SPLabeled {
                                            text: "Name:"
                                            label.opacity: 0.5

                                            Label {
                                                Layout.preferredWidth: 100
                                                text: modelData.text
                                                color: AlgStyle.text.color.normal
                                            }
                                        }

                                        Item { Layout.fillWidth: true }

                                        SPButton {
                                            padding: 5
                                            implicitWidth: 20
                                            implicitHeight: implicitWidth
                                            icon.source: "./SPWidgets/icons/close.png"
                                            icon.width: implicitWidth * 0.5
                                            icon.height: implicitHeight * 0.5
                                            tooltip.text: "Remove"
                                            backgroundRect.color: "black"
                                            backgroundRect.opacity: hovered ? 0.5 : 0.25

                                            onClicked: root.weaponList = root.weaponList.filter(w => w.value != modelData.value)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        SPButton {
            id: ignoreTexturesAreMissing
            text: "Ignore Textures Are Missing"
            checkable: true
            contentAlignment: Qt.ALignLeft | Qt.AlignVCenter
            Layout.fillWidth: true
        }

        RowLayout {
            id: footer
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SPButton {
                id: acceptButton
                text: "Save"
                enabled: root.cs2PathIsValid
                backgroundRect.opacity: hovered ? 1.0 : 0.65
                backgroundRect.color: "white"
                label.color: "#262626"
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.save()
            }

            SPButton {
                id: rejectButton
                text: "Close"
                backgroundRect.opacity: hovered ? 0.75 : 0.25
                backgroundRect.color: "black"
                label.color: AlgStyle.text.color.normal
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.close()
            }
        }
    }
}
