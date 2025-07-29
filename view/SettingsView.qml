import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import AlgWidgets.Style 2.0
import "./SPWidgets"

SPDialog {
    id: root
    color: AlgStyle.background.color.mainWindow
    confirm.text: "Save"

    QtObject {
        id: internal
        
        property string cs2Path: ""
        property bool cs2PathIsValid: true
        property var weaponList: []
        property bool weaponIsValid: false

        property var weaponFinish: {
            "finishStyle":            { control: finishStyleBox,         prop: "currentKey"   },
            "texScale":               { control: texScale,               prop: "value"        },
            "texRotationRange":       { control: texRotation,            prop: "range"        },
            "texOffsetXRange":        { control: texOffsetX,             prop: "range"        },
            "texOffsetYRange":        { control: texOffsetY,             prop: "range"        },
            "uIgnoreWeaponSizeScale": { control: ignoreWeaponSizeScale,  prop: "checked"      },
            "wearRange":              { control: wearRange,              prop: "range"        },
            "uUsePearlMask":          { control: usePearlescentMask,     prop: "checked"      },
            "uPearlScale":            { control: pearlescentScale,       prop: "value"        },
            "uUseCustomRough":        { control: useRoughnessTexture,    prop: "checked"      },
            "uPaintRoughness":        { control: paintRoughness,         prop: "value"        },
            "uCol0":                  { control: null,                   prop: "arrayColor"   },
            "uCol1":                  { control: null,                   prop: "arrayColor"   },
            "uCol2":                  { control: null,                   prop: "arrayColor"   },
            "uCol3":                  { control: null,                   prop: "arrayColor"   },
            "uUseCustomNormal":       { control: null,                   prop: "checked"      },
            "uUseCustomMasks":        { control: null,                   prop: "checked"      },
            "uUseCustomAOTex":        { control: null,                   prop: "checked"      }
        }

        onCs2PathChanged: cs2PathIsValid = cs2Path == "" ? true : Plugin.valCs2Path(cs2Path)

        function valWeapon() {
            const id = weaponIdInput.text.trim();
            const name = weaponNameInput.text.trim();
            let exists = false;
            for (const weapon of internal.weaponList)
                if (weapon.value == id || weapon.text == name) {
                    exists = true;
                    break;
                }
            weaponIsValid = id != "" && name != "" && !exists;
        }

        function addWeapon() {
            internal.weaponList = [{
                value: weaponIdInput.text.trim(),
                text: weaponNameInput.text.trim()
            }].concat(internal.weaponList);
            weaponIdInput.text = "";
            weaponNameInput.text = "";
            weaponIsValid = false;
        }
    }
    
    function getData() {
        const weapon_list = {};
        for (const weapon of internal.weaponList) // ReferenceError: internal is not defined
            weapon_list[weapon.value] = weapon.text;
        const weapon_finish = {};
        for (const [param, component] of Object.entries(internal.weaponFinish))
            weapon_finish[param] = component.control[component.prop];
        return {
            cs2_path: internal.cs2Path,
            weapon_list: weapon_list,
            weapon_finish: weapon_finish,
            ignore_textures_are_missing: ignoreTexturesAreMissing.checked
        }
    }

    onOpened: {
        try {
            const settings = JSON.parse(Plugin.getPluginSettings());
            if ("cs2_path" in settings)
                internal.cs2Path = settings["cs2_path"];
            if ("ignore_textures_are_missing" in settings)
                ignoreTexturesAreMissing.checked = settings["ignore_textures_are_missing"];
            if ("weapon_list" in settings) {
                const m = [];
                for (const [value, text] of Object.entries(settings["weapon_list"]))
                    m.push({value: value, text: text});
                internal.weaponList = m;
            }
            if ("weapon_finish" in settings) {
                for (const [param, value] of Object.entries(settings["weapon_finish"])) {
                    const component = internal.weaponFinish[param];
                    if (component !== undefined)
                        component.control[component.prop] = value;
                }
            }
        } catch (e) {
            Plugin.error(`Failed to open Plugin Settings: ${e.toString()}`);
        }
    }

    RowLayout {
        spacing: 15
        
        ColumnLayout {
            spacing: 15
            Layout.minimumWidth: 325
            Layout.fillWidth: true
            Layout.fillHeight: true
            
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
                        border.color: internal.cs2PathIsValid ? "transparent" : "red"
                        Layout.fillWidth: true
                        
                        SPTextInput {
                            id: cs2PathInput
                            anchors.fill: parent
                            anchors.margins: parent.border.width + 2
                            text: internal.cs2Path

                            onTextEdited: internal.cs2Path = text
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
                            folder: Qt.resolvedUrl(internal.cs2Path)

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
                                    tooltip.text: "Weapon Identifier"

                                    onTextEdited: internal.valWeapon()
                                }
                            }
                            
                            SPLabeled {
                                text: "Name:"

                                SPTextInput {
                                    id: weaponNameInput
                                    Layout.preferredWidth: 100
                                    tooltip.text: "Weapon Name"

                                    onTextEdited: internal.valWeapon()
                                }
                            }

                            Item { Layout.fillWidth: true }

                            SPButton {
                                text: "Add"
                                tooltip.text: "Add new weapon"
                                enabled: internal.weaponIsValid

                                onClicked: internal.addWeapon()
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
                                    model: internal.weaponList
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
                                                background.color: "black"
                                                background.opacity: hovered ? 0.5 : 0.25

                                                onClicked: internal.weaponList = internal.weaponList.filter(w => w.value != modelData.value)
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
        }

        SPSeparator {
            axis: SPSeparator.Vertical
            Layout.fillHeight: true
        }

        ColumnLayout {
            spacing: 15
            Layout.minimumWidth: 325
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                text: "Default Weapon Finish Settings"
                font.bold: true
                height: 20
                Layout.fillWidth: true
                color: AlgStyle.text.color.normal
            }

            Rectangle {
                id: weaponFinishBackground
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0.0, 0.0, 0.0, 0.1)

                ScrollView {
                    clip: true
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 5
                    anchors.bottomMargin: 10

                    ColumnLayout {
                        width: weaponFinishBackground.width - 30

                        SPLabeled {
                            text: "Common"
                            label.font.bold: true
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 10
                            SPSeparator { Layout.fillWidth: true }
                        }

                        SPLabeled {
                            text: "Finish Style"
                            Layout.fillWidth: true

                            SPComboBox {
                                id: finishStyleBox
                                Layout.fillWidth: true
                                Layout.fillHeight: true
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

                        SPSlider {
                            id: texScale
                            text: "Texture Scale"
                            from: -10
                            to: 10
                        }

                        SPButton {
                            id: ignoreWeaponSizeScale
                            text: "Ignore Weapon Size Scale"
                            checkable: true
                            tooltip.text: "For some finishes, the automatic scale adjustment per-weapon is not desired"
                            Layout.fillWidth: true
                            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        SPLabeled {
                            text: "Texture Placement"
                            label.font.bold: true
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 10
                            SPSeparator { Layout.fillWidth: true }
                        }

                        SPRangeSlider {
                            id: texRotation
                            text: "Texture Rotation"
                            from: -360
                            to: 360
                            pickValue: false
                        }

                        SPRangeSlider {
                            id: texOffsetX
                            text: "Texture Offset X"
                            from: -1
                            to: 1
                            pickValue: false
                        }

                        SPRangeSlider {
                            id: texOffsetY
                            text: "Texture Offset Y"
                            from: -1
                            to: 1
                            pickValue: false
                        }

                        SPLabeled {
                            text: "Color"
                            label.font.bold: true
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 10
                            SPSeparator { Layout.fillWidth: true }
                        }

                        Repeater {
                            model: 4
                            delegate: SPLabeled {
                                text: `Color${index}`
                                Layout.fillWidth: true

                                property alias arrayColor: colorPicker.arrayColor

                                SPColorButton { 
                                    id: colorPicker
                                    Layout.fillWidth: true
                                }
                            }
                            onItemAdded: (i, item) => internal.weaponFinish[`uCol${i}`].control = item
                        }
                        
                        SPLabeled {
                            text: "Effects"
                            label.font.bold: true
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 10
                            SPSeparator { Layout.fillWidth: true }
                        }

                        SPRangeSlider {
                            id: wearRange
                            text: "Wear Range"
                            minValue: 0.0
                            maxValue: 1.0
                            pickValue: false
                        }

                        SPButton {
                            id: usePearlescentMask
                            text: "Custom Pearlescent Mask"
                            Layout.fillWidth: true
                            checkable: true
                            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                        }

                        SPSlider {
                            id: pearlescentScale
                            text: "Pearlescent Scale"
                            from: -6
                            to: 6
                        }

                        SPButton {
                            id: useRoughnessTexture
                            text: "Custom Roughness Texture"
                            Layout.fillWidth: true
                            checkable: true
                            contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                        }
                            
                        SPSlider {
                            id: paintRoughness
                            text: "Paint Roughness"
                            from: 0
                            to: 1
                        }

                        SPLabeled {
                            text: "Advanced"
                            label.font.bold: true
                            Layout.fillWidth: true
                            Layout.topMargin: 20
                            Layout.bottomMargin: 10
                            SPSeparator { Layout.fillWidth: true }
                        }

                        Repeater {
                            model: [
                                { id: "uUseCustomNormal", text: "Custom Normal Map" },
                                { id: "uUseCustomMasks", text: "Custom Material Mask" },
                                { id: "uUseCustomAOTex", text: "Custom Ambient Occlusion" }
                            ]
                            delegate: SPButton {
                                checkable: true
                                text: modelData.text
                                tooltip.text: `Whether to use ${modelData.text.toLowerCase()} or the weapon default one`
                                Layout.fillWidth: true
                                contentAlignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                            onItemAdded: (i, item) => internal.weaponFinish[model[i].id].control = item
                        }
                    }
                }
            }
        }
    }
}
