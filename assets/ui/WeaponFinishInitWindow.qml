import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Window {
    id: root
    width: 400
    height: 300
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowSystemMenuHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    title: isNew ? "New Weapon Finish" : "Set up Weapon Finish"
    color: AlgStyle.background.color.mainWindow

    property bool isNew: true
    property string fileUrl: ""

    property real scopeWidth: width * 0.5

    signal proceed(string name, string weapon, int finishStyle, string fileUrl)

    function submit() {
        if (isNew)
            internal.createWeaponFinish(fileUrl, nameInput.text, weaponBox.currentValue, finishStyleBox.currentValue);
        else
            internal.setupAsWeaponFinish(nameInput.text, weaponBox.currentValue, finishStyleBox.currentValue);
        close();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        SPLabeled {
            text: "Name"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            Rectangle {
                color: "transparent"
                radius: 13.5
                height: 30
                border.width: 2
                border.color: false ? "green" : "red"
                Layout.fillWidth: true
                
                SPTextInput {
                    id: nameInput
                    anchors.fill: parent
                    anchors.margins: parent.border.width + 2

                    // onTextEdited: cs2PathMissingPopup.cs2Path = text
                }
            }
        }

        SPLabeled {
            text: "Mesh file"
            visible: root.isNew
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                
                Label {
                    text: root.fileUrl
                    clip: true
                    color: AlgStyle.text.color.normal
                    opacity: 0.5
                    elide: Text.ElideLeft
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }

                SPButton {
                    text: "Select"
                    
                    onClicked: fileDialog.open()

                    SPFileDialog {
                        id: fileDialog
                        title: "Select file"
                        nameFilters: [ "Mesh Files (*.fbx *.abc *.obj *.dae *.ply *.gltf *.glb *.usd *.usda *.usdc *.usdz)" ]
                        onAccepted: root.fileUrl = fileUrl.toString().substring(8);
                    }
                }
            }
        }

        SPSeparator { Layout.fillWidth: true }

        SPLabeled {
            text: "Finish Style"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            SPComboBox {
                id: finishStyleBox
                Layout.fillWidth: true
                model: [
                    { text: "Solid Color", value: 0 },
                    { text: "Hydrographic", value: 1 },
                    { text: "Spray Paint", value: 2 },
                    { text: "Anodized", value: 3 },
                    { text: "Anodized Multicolored", value: 4 },
                    { text: "Anodized Airbrushed", value: 5 },
                    { text: "Custom Paint Job", value: 6 },
                    { text: "Patina", value: 7 },
                    { text: "Gunsmith", value: 8 }
                ]
                textRole: "text"
                valueRole: "value"
            }
        }

        SPLabeled {
            text: "Weapon"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            SPComboBox {
                id: weaponBox
                textRole: "text"
                valueRole: "value"
                Layout.fillWidth: true
                model: {
                    const weaponList = internal.getWeaponList();
                    let weaponListModel = [];
                    for (const keyValue of weaponList.split("&")) {
                        const weapon = keyValue.split(":")
                        weaponListModel.push({
                            value: weapon[0],
                            text: weapon[1]
                        }); 
                    }
                    weaponListModel;
                }
            }
        }
        
        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SPButton {
                id: proceedButton
                text: root.isNew ? "Create" : "Proceed"
                backgroundRect.opacity: hovered ? 1.0 : 0.65
                backgroundRect.color: "white"
                label.color: "#262626"
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.submit()
            }

            SPButton {
                id: cancelButton
                text: "Cancel"
                backgroundRect.opacity: hovered ? 0.75 : 0.25
                backgroundRect.color: "black"
                label.color: AlgStyle.text.color.normal
                Layout.alignment: Qt.AlignHCenter

                onClicked: root.close()
            }
        }
    }
}
