import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    color: AlgStyle.background.color.mainWindow

    property bool isNew: true
    property string fileUrl: ""

    property real scopeWidth: width - 250

    Connections {
        target: Plugin
        
        function onOpened(isNew) {
            root.isNew = isNew;
            root.fileUrl = "";
            nameInput.name = "";
            weaponBox.currentKey = "";
            finishStyleBox.currentKey = Plugin.getDefaultFinishStyle();
        }
    }

    function confirm() {
        Plugin.confirm(JSON.stringify({
            file_path: fileUrl,
            finish_name: nameInput.name,
            weapon: weaponBox.currentKey,
            finish_style: finishStyleBox.currentKey
        }));
    }

    onFileUrlChanged: {
        for (const w of Object.keys(weaponBox.map))
            if (fileUrl.toLowerCase().indexOf(w.toLowerCase()) != -1) {
                weaponBox.currentKey = w;
                return;
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
        id: nameInput
        text: "Name"
        enabled: nameStatus > 0
        scopeWidth: root.scopeWidth
        Layout.fillWidth: true

        property string name: null
        property int nameStatus: 1
        property bool nameIsValid: nameStatus < 2;

        function valName() {
            nameStatus = Plugin.valWeaponFinishName(name);
        }

        onNameChanged: valName()

        Rectangle {
            color: "transparent"
            radius: 13.5
            width: 100
            height: 30
            border.width: 2
            border.color: nameInput.nameStatus > 0 ? (nameInput.nameIsValid ? "transparent" : "red") : "transparent"
            Layout.fillWidth: true
            
            SPTextInput {
                text: nameInput.name
                anchors.fill: parent
                anchors.margins: parent.border.width + 2

                onTextEdited: nameInput.name = text
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
            map: JSON.parse(Plugin.getWeaponList())
        }
    }
    
    SPLabeled {
        text: "Finish Style"
        scopeWidth: root.scopeWidth
        Layout.fillWidth: true

        SPComboBox {
            id: finishStyleBox
            Layout.fillWidth: true
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

        Label {
            id: nameStatusLabel
            clip: true
            opacity: 0.75
            Layout.fillWidth: true
            text: switch (nameInput.nameStatus) {
                case 0:
                    "Missing Plugin Path";
                    break;
                case 1:
                    "";
                    break;
                case 2:
                    "Name cannot be empty";
                    break;
                case 3:
                    "This name is already in use";
                    break;
            }
            color: switch (nameInput.nameStatus) {
                case 0:
                    Qt.rgba(0.85, 0.85, 0.5);
                    break;
                case 1:
                    Qt.rgba(0.85, 0.85, 0.85);
                    break;
                case 2:
                    Qt.rgba(0.85, 0.5, 0.5);
                    break;
                case 3:
                    Qt.rgba(0.85, 0.5, 0.5);
                    break;
            }
        }

        SPButton {
            id: confirmButton
            enabled: nameInput.nameIsValid && root.fileUrl !== "" && weaponBox.currentIndex != -1
            text: root.isNew ? "Create" : "Proceed"
            background.opacity: hovered ? 1.0 : 0.65
            background.color: "white"
            label.color: "#262626"
            Layout.alignment: Qt.AlignHCenter

            onClicked: root.confirm()
        }

        SPButton {
            id: cancelButton
            text: "Cancel"
            background.opacity: hovered ? 0.75 : 0.25
            background.color: "black"
            label.color: AlgStyle.text.color.normal
            Layout.alignment: Qt.AlignHCenter

            onClicked: root.close()
        }
    }
}
