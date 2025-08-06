import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    confirm.enabled: nameInput.nameIsValid && weaponBox.currentIndex != -1 && (isNew ? meshFile !== "" : true)
    confirm.text: isNew ? "Create" : "Proceed"
    message.text: switch (nameInput.nameStatus) {
        case 0:
            "Missing CS2 Path";
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
    message.color: switch (nameInput.nameStatus) {
        case 0:
            Qt.rgba(0.85, 0.85, 0.5);
            break;
        case 1:
            Qt.rgba(0.85, 0.5, 0.5);
            break;
        case 2:
            Qt.rgba(0.85, 0.5, 0.5);
            break;
        case 3:
            Qt.rgba(0.85, 0.5, 0.5);
            break;
    }

    property bool isNew: true
    property string meshFile: ""

    property real scopeWidth: width - 250

    Connections {
        target: Plugin
        
        function onOpened(isNew) {
            root.isNew = isNew;
            root.meshFile = "";
            nameInput.name = "name";
            weaponBox.currentKey = "";
            styleBox.currentKey = Plugin.getDefaultStyle();
        }
    }

    function getData() {
        return {
            mesh: meshFile,
            name: nameInput.name,
            style: styleBox.currentKey,
            weapon: weaponBox.currentKey
        }
    }

    onMeshFileChanged: {
        for (const w of Object.keys(weaponBox.map))
            if (meshFile.toLowerCase().indexOf(w.toLowerCase()) != -1) {
                weaponBox.currentKey = w;
                return;
            }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        
        SPLabeled {
            text: "Mesh file"
            visible: root.isNew
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: root.meshFile
                    clip: true
                    color: AlgStyle.text.color.normal
                    opacity: 0.5
                    elide: Text.ElideLeft
                    horizontalAlignment: Text.AlignLeft
                    Layout.fillWidth: true
                }

                SPButton {
                    text: "Select"
                    
                    onClicked: fileDialog.show()

                    SPFileDialog {
                        id: fileDialog
                        title: "Select file"
                        nameFilters: [ "Mesh Files (*.fbx *.abc *.obj *.dae *.ply *.gltf *.glb *.usd *.usda *.usdc *.usdz)" ]
                        onAccepted: root.meshFile = fileUrl.toString().substring(8);
                    }
                }
            }
        }

        SPSeparator { 
            visible: root.isNew
            Layout.fillWidth: true 
        }

        SPLabeled {
            id: nameInput
            text: "Name"
            enabled: nameStatus > 0
            scopeWidth: root.scopeWidth
            Layout.fillWidth: true

            property string name: ""
            property int nameStatus: 2
            property bool nameIsValid: nameStatus < 2;

            onNameChanged: nameStatus = name === "" ? 2 : Plugin.valWeaponFinishName(name)

            Rectangle {
                color: "transparent"
                radius: 13.5
                width: 100
                height: 30
                border.width: 2
                border.color: nameInput.nameStatus > 0 ? (nameInput.nameIsValid ? "transparent" : Qt.rgba(0.85, 0.15, 0.15)) : "transparent"
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
                id: styleBox
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
    }
}
