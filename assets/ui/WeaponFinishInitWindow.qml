import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

Window {
    id: root
    minimumWidth: 400
    minimumHeight: 250
    modality: Qt.ApplicationModal
    flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowSystemMenuHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
    title: isNew ? "New Weapon Finish" : "Set up Weapon Finish"
    color: AlgStyle.background.color.mainWindow

    property bool isNew: true
    property string fileUrl: ""

    property real scopeWidth: width * 0.25

    signal proceed(string name, string weapon, int finishStyle, string fileUrl)

    function submit() {
        if (isNew)
            internal.createWeaponFinish(fileUrl, nameInput.name, weaponBox.currentKey, finishStyleBox.currentKey);
        else
            internal.setupAsWeaponFinish(nameInput.name, weaponBox.currentKey, finishStyleBox.currentKey);
        close();
    }

    onFileUrlChanged: {
        for (const w of Object.keys(weaponBox.map))
            if (fileUrl.toLowerCase().indexOf(w.toLowerCase()) != -1) {
                weaponBox.currentKey = w;
                return;
            }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

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
            id: nameInput
            text: "Name"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            property string name: ""
            property bool nameIsValid: false

            function valName() {
                const nameStatus = internal.valWeaponFinishName(name);
                nameIsValid = nameStatus == 0;
                switch (nameStatus) {
                    case 1:
                        nameStatusLabel.text = "Name cannot be empty";
                        break;
                    case 2:
                        nameStatusLabel.text = "This name is already in use";
                        break;
                    default:
                        nameStatusLabel.text = "";
                }
            }

            Component.onCompleted: valName()

            onNameChanged: valName()

            RowLayout {
                Layout.fillWidth: true
                
                Label {
                    id: nameStatusLabel
                    clip: true
                    text: "Name cannot be empty"
                    color: Qt.rgba(0.85, 0.5, 0.5, 0.5)
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                }

                Rectangle {
                    color: "transparent"
                    radius: 13.5
                    width: 100
                    height: 30
                    border.width: 2
                    border.color: nameInput.nameIsValid ? "green" : "red"
                    
                    SPTextInput {
                        anchors.fill: parent
                        anchors.margins: parent.border.width + 2

                        onTextEdited: nameInput.name = text
                    }
                }
            }
        }

        SPLabeled {
            text: "Weapon"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            SPComboBox {
                id: weaponBox
                currentIndex: -1
                Layout.fillWidth: true
                map: JSON.parse(internal.getWeaponList())
            }
        }
        
        SPLabeled {
            text: "Finish Style"
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            SPComboBox {
                id: finishStyleBox
                Layout.fillWidth: true
                currentIndex: 8
                map: {
                    "so": "Solid Color",
                    "hy": "Hydrographic",
                    "sp": "Spray Paint",
                    "an": "Anodized",
                    "am": "Anodized Multicolored",
                    "aa": "Anodized Airbrushed",
                    "cu": "Custom Paint Job",
                    "aq": "Patina",
                    "gs": "Gunsmith"
                }
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true

            Item { Layout.fillWidth: true }

            SPButton {
                id: proceedButton
                enabled: nameInput.nameIsValid && root.fileUrl !== "" && weaponBox.currentIndex != -1
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
